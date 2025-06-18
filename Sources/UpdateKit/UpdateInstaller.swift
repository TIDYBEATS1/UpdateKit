import Foundation
import AppKit

public enum UpdateInstaller {
    private static var downloadObservation: NSKeyValueObservation?

    /// Prompt for admin once, up-front
    private static func requestAdminPrivileges() throws {
        let script = """
        do shell script "true" with administrator privileges
        """
        var errorDict: NSDictionary?
        let apple = NSAppleScript(source: script)!
        apple.executeAndReturnError(&errorDict)
        if let err = errorDict {
            let msg = err[NSAppleScript.errorMessage] as? String
            throw NSError(domain: "UpdateInstaller",
                          code: 2,
                          userInfo: [NSLocalizedDescriptionKey: msg ?? "User denied permission"])
        }
    }

    public static func downloadAndInstall(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // 1️⃣ Ask for perms before we do anything
        do {
            try requestAdminPrivileges()
        } catch {
            return completion(false, error)
        }

        // 2️⃣ Now start download + unpack + install as before
        downloadAndUnpack(from: url, progress: progress) { result in
            downloadObservation = nil

            switch result {
            case .success(let newAppURL):
                if isBundleWritable() {
                    do { try replaceInPlace(newAppURL: newAppURL); return completion(true, nil) }
                    catch { /* fall through */ }
                }
                do { try installToUserApplications(newAppURL: newAppURL); return completion(true, nil) }
                catch { /* fall through */ }

                let (ok, errMsg) = privilegedCopyToApplications(appURL: newAppURL)
                let nsErr = errMsg.map {
                    NSError(domain: "UpdateInstaller", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: $0])
                }
                completion(ok, nsErr)

            case .failure(let error):
                completion(false, error)
            }
        }
    }

    // MARK: – Step 1: replace in-place

    private static func isBundleWritable() -> Bool {
        FileManager.default.isWritableFile(atPath: Bundle.main.bundleURL.path)
    }

    private static func replaceInPlace(newAppURL: URL) throws {
        let current = Bundle.main.bundleURL
        let fm = FileManager.default
        try fm.removeItem(at: current)
        try fm.moveItem(at: newAppURL, to: current)
    }

    // MARK: – Step 2: user‐level Applications

    private static func installToUserApplications(newAppURL: URL) throws {
        let fm       = FileManager.default
        let userApps = fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
        let dest     = userApps.appendingPathComponent(newAppURL.lastPathComponent)
        try fm.createDirectory(at: userApps, withIntermediateDirectories: true)
        if fm.fileExists(atPath: dest.path) {
            try fm.removeItem(at: dest)
        }
        try fm.moveItem(at: newAppURL, to: dest)
    }

    // MARK: – Step 3: admin prompt fallback

    @discardableResult
    private static func privilegedCopyToApplications(appURL: URL) -> (Bool, String?) {
        let dest = URL(fileURLWithPath: "/Applications")
            .appendingPathComponent(appURL.lastPathComponent)

        let script = """
        do shell script "rm -rf '\(dest.path)' && cp -R '\(appURL.path)' '\(dest.path)'" with administrator privileges
        """

        var errorDict: NSDictionary?
        let apple = NSAppleScript(source: script)!
        _ = apple.executeAndReturnError(&errorDict)

        if let err = errorDict {
            let msg = err[NSAppleScript.errorMessage] as? String
            return (false, msg)
        }

        return (true, nil)
    }

    // MARK: – Download & unzip helper

    private static func downloadAndUnpack(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, err in
            guard let tmp = tempURL else {
                return completion(.failure(err ?? NSError(domain: "DownloadError", code: -1)))
            }

            let fm       = FileManager.default
            let unpacked = fm.temporaryDirectory.appendingPathComponent("UpdateUnpacked")
            try? fm.removeItem(at: unpacked)
            try? fm.createDirectory(at: unpacked, withIntermediateDirectories: true)

            let unzip = Process()
            unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            unzip.arguments     = ["-o", tmp.path, "-d", unpacked.path]
            unzip.terminationHandler = { _ in
                let files = try? fm.contentsOfDirectory(at: unpacked, includingPropertiesForKeys: nil)
                if let app = files?.first(where: { $0.pathExtension == "app" }) {
                    completion(.success(app))
                } else {
                    completion(.failure(NSError(domain: "UnzipError", code: 1)))
                }
            }

            do {
                try unzip.run()
            } catch {
                completion(.failure(error))
            }
        }

        // KEEP the observation around until download finishes
        downloadObservation = task.progress.observe(\.fractionCompleted, options: [.new]) { prog, _ in
            DispatchQueue.main.async {
                progress(prog.fractionCompleted)
            }
        }

        task.resume()
    }
}
