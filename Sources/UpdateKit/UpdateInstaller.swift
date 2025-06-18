import Foundation
import AppKit

public enum UpdateInstaller {
    private static var downloadObservation: NSKeyValueObservation?

    /// Downloads a ZIP from the given URL into ~/Downloads,
    /// unpacks it there, and reveals the new .app in Finder.
    public static func downloadToDownloads(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // 1️⃣ Find Downloads folder
        guard let downloadsURL = FileManager.default
                .urls(for: .downloadsDirectory, in: .userDomainMask)
                .first
        else {
            return completion(false,
                NSError(domain: "UpdateInstaller",
                        code: 10,
                        userInfo: [NSLocalizedDescriptionKey: "Could not locate Downloads folder"]))
        }

        // 2️⃣ Prepare destination ZIP path
        let zipName = url.lastPathComponent
        let destZip = downloadsURL.appendingPathComponent(zipName)

        // 3️⃣ Start download
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            // cleanup observation
            downloadObservation = nil

            guard let tmp = tempURL, error == nil else {
                return completion(false, error)
            }

            do {
                let fm = FileManager.default
                // remove old ZIP if present
                if fm.fileExists(atPath: destZip.path) {
                    try fm.removeItem(at: destZip)
                }
                // move freshly-downloaded ZIP into ~/Downloads
                try fm.moveItem(at: tmp, to: destZip)
            } catch {
                return completion(false, error)
            }

            // 4️⃣ Unpack into a known subfolder
            let unpackDir = downloadsURL.appendingPathComponent("PS5NORMacApp-Update")
            do {
                try FileManager.default.removeItem(at: unpackDir)
                try FileManager.default.createDirectory(at: unpackDir,
                                                        withIntermediateDirectories: true)
            } catch {
                // non‐fatal—will try to overwrite later
            }

            let unzip = Process()
            unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            unzip.arguments     = ["-o", destZip.path, "-d", unpackDir.path]

            do {
                try unzip.run()
                unzip.waitUntilExit()
            } catch {
                return completion(false, error)
            }

            // 5️⃣ Find the new .app bundle
            let apps = (try? FileManager.default
                          .contentsOfDirectory(at: unpackDir,
                                               includingPropertiesForKeys: nil)) ?? []
            guard let newApp = apps.first(where: { $0.pathExtension == "app" }) else {
                return completion(false,
                    NSError(domain: "UpdateInstaller",
                            code: 11,
                            userInfo: [NSLocalizedDescriptionKey: "No .app found in update"]))
            }

            // 6️⃣ Reveal in Finder
            DispatchQueue.main.async {
                NSWorkspace.shared.activateFileViewerSelecting([newApp])
            }

            // Done!
            completion(true, nil)
        }

        // Observe progress
        downloadObservation = task.progress.observe(\.fractionCompleted, options: [.new]) { prog, _ in
            DispatchQueue.main.async {
                progress(prog.fractionCompleted)
            }
        }

        task.resume()
    }
}
