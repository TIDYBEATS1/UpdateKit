import Foundation
import SwiftUI
import AppKit

public final class UpdateManager: ObservableObject {
    // MARK: Published state for your UI
    @Published public var status: String = ""
    @Published public var isUpdating: Bool = false
    @Published public var installSucceeded: Bool = false
    @Published public var downloadProgress: Double = 0.0
    @Published public var pendingUpdate: UpdateInfo?   // ← drives your .sheet(item:)

    private let repo: String

    /// Provide your "owner/repo" once when you create the manager
    public init(repo: String) {
        self.repo = repo
    }

    // MARK: — Public API

    /// Check GitHub for the latest release; on success, sets `pendingUpdate` only if it's newer
    public func checkForUpdates() {
        // 1️⃣ Read your app’s current version
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"

        status = "Checking for updates…"
        GitHubReleaseChecker.fetchLatestRelease(repo: repo) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let release):
                    // 2️⃣ Compare tag_name (e.g. "1.2.3") to your CFBundleShortVersionString
                    if release.version.compare(currentVersion, options: .numeric) == .orderedDescending {
                        // new version available
                        self.status = "Update to v\(release.version) available"
                        self.pendingUpdate = UpdateInfo(
                            version:     release.version,
                            downloadURL: release.downloadURL,
                            patchNotes:  release.patchNotes
                        )
                    } else {
                        // already on latest
                        self.status = "✅ You’re up to date (v\(currentVersion))"
                        self.pendingUpdate = nil
                    }

                case .failure(let err):
                    self.status = "❌ Update check failed: \(err.localizedDescription)"
                    self.pendingUpdate = nil
                }
            }
        }
    }

    /// Kick off the download → unpack → install flow
    public func startUpdate(from info: UpdateInfo) {
        // 1️⃣ Kick off the UI
        DispatchQueue.main.async {
            self.isUpdating     = true
            self.status         = "Starting update…"
            self.downloadProgress = 0.0
        }

        // 2️⃣ Download into ~/Downloads
        UpdateInstaller.downloadToDownloads(
            from: info.downloadURL,
            progress: { fraction in
                DispatchQueue.main.async {
                    self.downloadProgress = fraction
                    self.status = "Downloading… \(Int(fraction * 100))%"
                }
            },
            completion: { success, error in
                DispatchQueue.main.async {
                    self.isUpdating = false

                    if success {
                        self.status           = "✅ Download complete. Check your Downloads folder."
                        self.installSucceeded = true
                        // If you had a relaunch prompt, you could call it here:
                        // self.promptRelaunch()
                    }
                    else {
                        let message = error?.localizedDescription ?? "Unknown error"
                        self.status           = "❌ Update failed: \(message)"
                        self.installSucceeded = false
                    }
                }
            }
        )
    }
    // MARK: — Helpers

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
