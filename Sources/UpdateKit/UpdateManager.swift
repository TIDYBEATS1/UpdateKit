import Foundation
import SwiftUI

public final class UpdateManager: ObservableObject {
    @Published public var status: String = ""
    @Published public var isUpdating: Bool = false
    @Published public var installSucceeded: Bool = false
    @Published public var downloadProgress: Double = 0.0
    @Published public var pendingUpdate: UpdateInfo?    // ← sheet(item:)

    private let repo: String

    /// Now you inject your "owner/repo" once when you create the manager
    public init(repo: String) {
        self.repo = repo
    }
    
    /// Kick off a GitHub “latest release” check, fills pendingUpdate on success
    public func checkForUpdates() {
        status = "Checking for updates…"
        GitHubReleaseChecker.fetchLatestRelease(repo: repo) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let release):
                    self.pendingUpdate = UpdateInfo(
                        version:     release.version,
                        downloadURL: release.downloadURL,
                        patchNotes:  release.patchNotes
                    )
                    self.status = "Update \(release.version) available"
                case .failure(let err):
                    self.status = "❌ \(err.localizedDescription)"
                }
            }
        }
    }
    
    /// Starts the full download → unpack → install flow
    public func startUpdate(from info: UpdateInfo) {
        DispatchQueue.main.async {
            self.isUpdating = true
            self.status = "Starting update…"
            self.downloadProgress = 0.0
        }
        
        UpdateInstaller.downloadAndInstall(from: info.downloadURL,
                                           progress: { p in
            DispatchQueue.main.async {
                self.downloadProgress = p
                self.status = "Downloading… \(Int(p * 100))%"
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
