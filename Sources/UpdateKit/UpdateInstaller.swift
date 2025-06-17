import Foundation

public enum UpdateInstaller {

    /// Downloads the ZIP archive from the provided URL and extracts the first `.app` bundle.
    public static func downloadAndUnpack(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL else {
                completion(.failure(error ?? NSError(domain: "DownloadError", code: -1)))
                return
            }

            let fileManager = FileManager.default
            let unzipDir = fileManager.temporaryDirectory.appendingPathComponent("UpdateUnpacked")

            try? fileManager.removeItem(at: unzipDir)
            try? fileManager.createDirectory(at: unzipDir, withIntermediateDirectories: true)

            let unzipProcess = Process()
            unzipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            unzipProcess.arguments = ["-o", tempURL.path, "-d", unzipDir.path]

            unzipProcess.terminationHandler = { _ in
                let contents = try? fileManager.contentsOfDirectory(at: unzipDir, includingPropertiesForKeys: nil)
                if let appURL = contents?.first(where: { $0.pathExtension == "app" }) {
                    completion(.success(appURL))
                } else {
                    completion(.failure(NSError(domain: "UnzipError", code: 1)))
                }
            }

            do {
                try unzipProcess.run()
            } catch {
                completion(.failure(error))
            }
        }

        // 👇 Add this line to track progress live
        _ = task.progress.observe(\.fractionCompleted) { prog, _ in
            DispatchQueue.main.async {
                progress(prog.fractionCompleted)
            }
        }

        task.resume()
    }

    /// Replaces the current running app with the provided `.app` bundle.
    public static func replaceCurrentApp(with newAppURL: URL, completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        let appName = newAppURL.lastPathComponent
        let destinationURL = URL(fileURLWithPath: "/Applications").appendingPathComponent(appName)

        print("📦 Installing to: \(destinationURL.path)")

        do {
            // Ensure app exists at unpacked location
            guard fileManager.fileExists(atPath: newAppURL.path) else {
                print("❌ New app not found at: \(newAppURL.path)")
                completion(false)
                return
            }

            // Remove existing if present
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            // Copy the new app
            try fileManager.copyItem(at: newAppURL, to: destinationURL)
            print("✅ Copied to /Applications")
            completion(true)
        } catch {
            print("❌ Install error: \(error)")
            completion(false)
        }
    }
}
