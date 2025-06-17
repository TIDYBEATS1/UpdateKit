import Foundation
import SwiftUI

public final class UpdateManager: ObservableObject {
    @Published public var status: String = ""
    @Published public var isUpdating: Bool = false
    @Published public var installSucceeded: Bool = false
    @Published public var downloadProgress: Double = 0.0  // ✅ NEW
    
    public init() {}
    
    public func startUpdate(from info: UpdateInfo) {
        DispatchQueue.main.async {
            self.isUpdating = true
            self.status = "Downloading update..."
            self.downloadProgress = 0.0
        }
        
        UpdateInstaller.downloadAndUnpack(from: info.downloadURL, progress: { progress in
            DispatchQueue.main.async {
                self.downloadProgress = progress
                self.status = String(format: "Downloading... %.0f%%", progress * 100)
            }
        }, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let appURL):
                    self.status = "Installing update..."
                    
                    UpdateInstaller.replaceCurrentApp(with: appURL) { success in
                        DispatchQueue.main.async {
                            self.installSucceeded = success
                            self.status = success ? "✅ Update installed." : "❌ Install failed."
                            self.isUpdating = false
                            
                            if success {
                                AppReplacer.replaceCurrentApp(with: appURL)
                                self.promptRelaunch()
                            }
                        }
                    }
                    
                case .failure(let error):
                    self.status = "❌ Update failed: \(error.localizedDescription)"
                    self.isUpdating = false
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
