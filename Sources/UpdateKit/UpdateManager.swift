//
//  UpdateManager.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import Foundation
import SwiftUI

public final class UpdateManager: ObservableObject {
    @Published public var status: String = ""
    @Published public var isUpdating: Bool = false
    @Published public var installSucceeded: Bool = false

    public init() {}

    public func startUpdate(from info: UpdateInfo) {
        DispatchQueue.main.async {
            self.isUpdating = true
            self.status = "Downloading update..."
        }

        UpdateInstaller.downloadAndUnpack(from: info.downloadURL) { result in
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
                                self.promptRelaunch()
                            }
                        }
                    }

                case .failure(let error):
                    self.status = "❌ Update failed: \(error.localizedDescription)"
                    self.isUpdating = false
                }
            }
        }
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