import Foundation
import AppKit

public enum UpdateInstaller {
    /// Downloads the ZIP archive from the provided URL and extracts the first `.app` bundle.
    public static func downloadAndInstall(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        downloadAndUnpack(from: url, progress: progress) { result in
            switch result {
            case .success(let newAppURL):
                // 1️⃣ Try in-place replacement
                if isBundleWritable() {
                    do {
                        try replaceInPlace(newAppURL: newAppURL)
                        completion(true, nil)
                        return
                    } catch {
                        // fall through to next step
                    }
                }

                // 2️⃣ Try user-level Applications
                do {
                    try installToUserApplications(newAppURL: newAppURL)
                    completion(true, nil)
                    return
                } catch {
                    // fall through to next step
                }

                // 3️⃣ Last resort: admin prompt copy
                let (ok, errMsg) = privilegedCopyToApplications(appURL: newAppURL)
                let err = errMsg.map {
                    NSError(domain: "UpdateInstaller", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: $0])
                }
                completion(ok, err)

            case .failure(let error):
                completion(false, error)
            }
        }
    }

    // MARK: - Step 1: In-place replacement

    private static func isBundleWritable() -> Bool {
        FileManager.default.isWritableFile(atPath: Bundle.main.bundleURL.path)
    }

    private static func replaceInPlace(newAppURL: URL) throws {
        let currentURL = Bundle.main.bundleURL
        let fm = FileManager.default
        try fm.removeItem(at: currentURL)
        try fm.moveItem(at: newAppURL, to: currentURL)
    }

    // MARK: - Step 2: User-level Applications

    private static func installToUserApplications(newAppURL: URL) throws {
        let fm = FileManager.default
        let userApps = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Applications")
        let dest = userApps.appendingPathComponent(newAppURL.lastPathComponent)
        try fm.createDirectory(at: userApps, withIntermediateDirectories: true)
        if fm.fileExists(atPath: dest.path) {
            try fm.removeItem(at: dest)
        }
        try fm.moveItem(at: newAppURL, to: dest)
    }

    // MARK: - Step 3: Admin prompt fallback

    @discardableResult
    private static func privilegedCopyToApplications(appURL: URL) -> (Bool, String?) {
        let scriptSource = #"do shell script \"cp -R \"\(appURL.path)\" /Applications/\" with administrator privileges"#
        var errorDict: NSDictionary?
        guard let script = NSAppleScript(source: scriptSource) else {
            return (false, "Failed to create AppleScript.")
        }
        script.executeAndReturnError(&errorDict)
        if let err = errorDict {
            return (false, err[NSAppleScript.errorMessage] as? String)
        }
        return (true, nil)
    }

    // MARK: - Helper: Download & Unpack

    private static func downloadAndUnpack(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL else {
                completion(.failure(error ?? NSError(domain: "DownloadError", code: -1)))
                return
            }
            let fm = FileManager.default
            let unzipDir = fm.temporaryDirectory.appendingPathComponent("UpdateUnpacked")
            try? fm.removeItem(at: unzipDir)
            try? fm.createDirectory(at: unzipDir, withIntermediateDirectories: true)
            let unzip = Process()
            unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            unzip.arguments = ["-o", tempURL.path, "-d", unzipDir.path]
            unzip.terminationHandler = { _ in
                let contents = try? fm.contentsOfDirectory(at: unzipDir, includingPropertiesForKeys: nil)
                if let appURL = contents?.first(where: { $0.pathExtension == "app" }) {
                    completion(.success(appURL))
                } else {
                    completion(.failure(NSError(domain: "UnzipError", code: 1)))
                }
            }
            do { try unzip.run() } catch { completion(.failure(error)) }
        }
        // KVO observe using keyPath API
        _ = task.progress.observe(\.fractionCompleted, options: [.new]) { prog, _ in
            DispatchQueue.main.async {
                progress(prog.fractionCompleted)
            }
        }
        task.resume()
    }
}
