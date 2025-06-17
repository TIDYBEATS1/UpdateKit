import Foundation
import AppKit   // for NSAppleScript

public enum UpdateInstaller {

    /// Downloads the ZIP, unpacks the first `.app`, then installs it to /Applications
    public static func downloadUnpackAndInstall(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // 1) Download
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL else {
                DispatchQueue.main.async {
                    completion(false, error ?? NSError(domain: "DownloadError", code: -1))
                }
                return
            }

            // 2) Unpack
            let fileManager = FileManager.default
            let unzipDir = fileManager.temporaryDirectory.appendingPathComponent("UpdateUnpacked")
            try? fileManager.removeItem(at: unzipDir)
            try? fileManager.createDirectory(at: unzipDir, withIntermediateDirectories: true)

            let unzip = Process()
            unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            unzip.arguments = ["-o", tempURL.path, "-d", unzipDir.path]
            unzip.terminationHandler = { _ in

                let contents = (try? fileManager.contentsOfDirectory(at: unzipDir, includingPropertiesForKeys: nil)) ?? []
                guard let appURL = contents.first(where: { $0.pathExtension == "app" }) else {
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "UnzipError", code: 1))
                    }
                    return
                }

                // 3) Install via AppleScript (privileged copy)
                let success = privilegedCopyToApplications(appURL: appURL)
                DispatchQueue.main.async {
                    completion(success, success ? nil : NSError(domain: "InstallError", code: 2))
                }
            }

            do {
                try unzip.run()
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }

        // progress bar
        _ = task.progress.observe(\.fractionCompleted) { prog, _ in
            DispatchQueue.main.async {
                progress(prog.fractionCompleted)
            }
        }

        task.resume()
    }

    /// Uses AppleScript `do shell script ... with administrator privileges`
    /// to copy the `.app` into /Applications.
    static private func privilegedCopyToApplications(appURL: URL) -> Bool {
        let src  = appURL.path.replacingOccurrences(of: "'", with: "'\\''")
        let dst  = "/Applications/\(appURL.lastPathComponent)".replacingOccurrences(of: "'", with: "'\\''")
        let script = """
        do shell script "cp -R '\(src)' '\(dst)'" with administrator privileges
        """

        var errorInfo: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(&errorInfo)

        if let err = errorInfo {
            print("❌ Privileged copy failed: \(err)")
            return false
        } else {
            print("✅ Copied to /Applications via AppleScript")
            return true
        }
    }
}
