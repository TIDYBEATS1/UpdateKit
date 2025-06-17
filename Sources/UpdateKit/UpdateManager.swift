import Foundation
import SwiftUI

public final class UpdateManager: ObservableObject {
    @Published public var status: String = ""
    @Published public var isUpdating: Bool = false
    @Published public var installSucceeded: Bool = false
    @Published public var downloadProgress: Double = 0.0  // ✅ NEW
    @Published public var installError: String?
    @Published public var showRetryAlert = false
    public init() {}
    
    public func startUpdate(from info: UpdateInfo) {
        isUpdating = true
        status     = "Downloading…"

        UpdateInstaller.downloadUnpackAndInstall(
            from: info.downloadURL,
            progress: { p in
                DispatchQueue.main.async {
                    self.downloadProgress = p
                    self.status = String(format: "Downloading… %.0f%%", p * 100)
                }
            },
            completion: { success, error in
                DispatchQueue.main.async {
                    self.isUpdating = false

                    if success {
                        self.status = "✅ Update installed."
                        self.promptRelaunch()
                    } else {
                        // set the error message and show retry alert
                        self.installError    = error?.localizedDescription ?? "Authentication failed"
                        self.showRetryAlert  = true
                    }
                }
            }
        )
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
    
    @Published public var estimatedDownloadSizeMB: Double? = nil
    
    public func estimateDownloadSize(from url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let size = response?.expectedContentLength, size > 0 {
                DispatchQueue.main.async {
                    self.estimatedDownloadSizeMB = Double(size) / 1_048_576
                }
            }
        }.resume()
    }
}
