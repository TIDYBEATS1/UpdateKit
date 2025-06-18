import Foundation
import AppKit

public enum UpdateInstaller {
    private static var downloadObservation: NSKeyValueObservation?

    // MARK: – Step 0: Ask once for Admin privileges up front
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

    // MARK: – Public entry point
    public static func downloadAndInstall(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // 1️⃣ Ask for admin up front
        do {
            try requestAdminPrivileges()
        } catch {
            return completion(false, error)
        }

        // 2️⃣ Locate the Downloads folder
        guard let downloadsURL = FileManager.default
                .urls(for: .downloadsDirectory, in: .userDomainMask)
                .first
        else {
            return completion(false,
                              NSError(domain: "UpdateInstaller",
                                      code: 3,
                                      userInfo: [NSLocalizedDescriptionKey: "Downloads folder not found"]))
        }

        // 3️⃣ Kick off download/unpack/install
        downloadAndUnpack(from: url,
                          into: downloadsURL.appendingPathComponent("PS5NORMacApp-Update", isDirectory: true),
                          progress: progress) { result in
            downloadObservation = nil

            switch result {
            case .success(let newAppURL):
                // Try the three install strategies in order:
                if isBundleWritable() {
                    do { try replaceInPlace(newAppURL: newAppURL); return completion(true, nil) }
                    catch { /* fallthrough */ }
                }
                do { try installToUserApplications(newAppURL: newAppURL); return completion(true, nil) }
                catch { /* fallthrough */ }

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

    // MARK: – Download + Unpack helper
    private static func downloadAndUnpack(
        from url: URL,
        into unpackDir: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let fm = FileManager.default
        // 1️⃣ Prepare your unpack directory
        try? fm.removeItem(at: unpackDir)
        try? fm.createDirectory(at: unpackDir, withIntermediateDirectories: true)

        let task = URLSession.shared.downloadTask(with: url) { tmpURL, _, err in
            guard let tmpURL = tmpURL else {
                return completion(.failure(err ?? NSError(domain: "DownloadError", code: -1)))
            }

            // 2️⃣ Unpack using ditto
            let unzip = Process()
            unzip.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            unzip.arguments     = ["-xk", tmpURL.path, unpackDir.path]

            // 3️⃣ Termination handler must be Sendable—so re-fetch FileManager inside
            unzip.terminationHandler = { _ in
                // ⚠️ Don’t capture the outer `fm`; grab a fresh one here
                let localFM = FileManager.default
                let files = (try? localFM.contentsOfDirectory(at: unpackDir, includingPropertiesForKeys: nil)) ?? []

                if let app = files.first(where: { $0.pathExtension == "app" }) {
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

        // Observe download progress as before
        downloadObservation = task.progress.observe(\.fractionCompleted, options: [.new]) { prog, _ in
            DispatchQueue.main.async { progress(prog.fractionCompleted) }
        }

        task.resume()
    }
    // MARK: – Install strategies (as you already have them) …

    private static func isBundleWritable() -> Bool {
        FileManager.default.isWritableFile(atPath: Bundle.main.bundleURL.path)
    }

    private static func replaceInPlace(newAppURL: URL) throws {
        let current = Bundle.main.bundleURL
        let fm = FileManager.default
        try fm.removeItem(at: current)
        try fm.moveItem(at: newAppURL, to: current)
    }

    private static func installToUserApplications(newAppURL: URL) throws {
        let fm       = FileManager.default
        let userApps = fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
        try fm.createDirectory(at: userApps, withIntermediateDirectories: true)
        let dest     = userApps.appendingPathComponent(newAppURL.lastPathComponent)
        if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
        try fm.moveItem(at: newAppURL, to: dest)
    }

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
        if let e = errorDict {
            return (false, e[NSAppleScript.errorMessage] as? String)
        }
        return (true, nil)
    }
}
