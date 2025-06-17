// UpdatePromptView.swift

import SwiftUI

public struct UpdatePromptView: View {
    public let info: UpdateInfo
    @ObservedObject public var manager: UpdateManager     // ← injected
    public let onInstall: () -> Void
    public let onCancel:  () -> Void

    public init(
        info: UpdateInfo,
        manager: UpdateManager,
        onInstall: @escaping () -> Void,
        onCancel:  @escaping () -> Void
    ) {
        self.info      = info
        self.manager   = manager
        self.onInstall = onInstall
        self.onCancel  = onCancel
    }

    public var body: some View {
        VStack(spacing: 24) {
            Button("Update Now") {
                manager.estimateDownloadSize(from: info.downloadURL)
                manager.startUpdate(from: info)
                onInstall()
            }
        }
        .padding(24)
        .frame(width: 480)
        // ← attach the retry alert here, using the injected manager
        .alert(
            "Installation Failed",
            isPresented: $manager.showRetryAlert,
            actions: {
                Button("Retry") {
                    manager.startUpdate(from: info)
                }
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
            },
            message: {
                Text(manager.installError ?? "An unknown error occurred.")
            }
        )
    }
}
