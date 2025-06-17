import Foundation
import SwiftUI

public final class UpdateManager: ObservableObject {
    @Published public var status: String = ""
    @Published public var isUpdating: Bool = false
    @Published public var installSucceeded: Bool = false
    @Published public var downloadProgress: Double = 0.0

    public init() {}

    /// Starts the full update/install flow from a given UpdateInfo
    public func startUpdate(from info: UpdateInfo) {
        DispatchQueue.main.async {
            self.isUpdating = true
            self.status = "Starting update..."
            self.downloadProgress = 0.0
        }

        UpdateInstaller.downloadAndInstall(from: info.downloadURL,
                                          progress: { progress in
                                            DispatchQueue.main.async {
                                                self.downloadProgress = progress
                                                let percent = Int(progress * 100)
                                                self.status = "Downloading… \(percent)%"
                                            }
                                          },
                                          completion: { success, error in
                                            DispatchQueue.main.async {
                                                self.isUpdating = false
                                                if success {
                                                    self.status = "✅ Update installed."
                                                    self.installSucceeded = true
                                                    self.promptRelaunch()
                                                } else {
                                                    self.status = "❌ Update failed: \(error?.localizedDescription ?? "Unknown error")"
                                                    self.installSucceeded = false
                                                }
                                            }
                                          })
    }

    private func promptRelaunch() {
        let alert = NSAlert()
        alert.messageText = "Update Installed"
        alert.informativeText = "The app will now relaunch to complete the update."
        alert.addButton(withTitle: "Relaunch Now")
        alert.runModal()
        relaunchApp()
    }

    private func relaunchApp() {
        let path = Bundle.main.bundlePath
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        try? task.run()
        exit(0)
    }
}
