import Foundation
import AppKit

public enum UpdateInstaller {
    /// Downloads the ZIP, unpacks it, then installs via one of three strategies:
    /// 1) In-place (if you shipped unsigned & it’s writable)
    /// 2) ~/Applications (no privileges)
    /// 3) /Applications via an admin prompt
    public static func downloadAndInstall(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        downloadAndUnpack(from: url, progress: progress) { result in
            switch result {
            case .success(let newAppURL):
                print("✅ [Updater] Downloaded new build to:", newAppURL.path)

                // 1️⃣ In-place
                if isBundleWritable() {
                    do {
                        try replaceInPlace(newAppURL: newAppURL)
                        print("🔄 [Updater] Replaced in-place at:", Bundle.main.bundleURL.path)
                        return completion(true, nil)
                    } catch {
                        print("⚠️ [Updater] replaceInPlace failed:", error)
                    }
                } else {
                    print("ℹ️ [Updater] Bundle not writable at:", Bundle.main.bundleURL.path)
                }

                // 2️⃣ ~/Applications
                do {
                    try installToUserApplications(newAppURL: newAppURL)
                    print("🔄 [Updater] Installed to ~/Applications:", newAppURL.lastPathComponent)
                    return completion(true, nil)
                } catch {
                    print("⚠️ [Updater] installToUserApplications failed:", error)
                }

                // 3️⃣ /Applications with admin prompt
                let (ok, errMsg) = privilegedCopyToApplications(appURL: newAppURL)
                print("🔄 [Updater] privilegedCopyToApplications ok? \(ok), errMsg:", errMsg ?? "none")
                let nsErr = errMsg.map {
                    NSError(domain: "UpdateInstaller", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: $0])
                }
                return completion(ok, nsErr)

            case .failure(let error):
                print("❌ [Updater] downloadAndUnpack failed:", error)
                return completion(false, error)
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

    // MARK: – Step 2: user-level Applications
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
            do { try unzip.run() } catch { completion(.failure(error)) }
        }

        // Keep the observation alive until download completes
        var observation: NSKeyValueObservation? = nil
        observation = task.progress.observe(\.fractionCompleted, options: [.new]) { prog, _ in
            DispatchQueue.main.async {
                progress(prog.fractionCompleted)
            }
            if prog.fractionCompleted >= 1.0 {
                observation?.invalidate()
                observation = nil
            }
        }

        task.resume()
    }
}
