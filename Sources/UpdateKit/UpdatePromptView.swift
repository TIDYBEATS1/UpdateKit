import SwiftUI

public struct UpdatePromptView: View {
    public let info: UpdateInfo
    @ObservedObject public var manager: UpdateManager
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
        VStack(spacing: 16) {
            Text("New Version: \(info.version)")
                .font(.headline)

            Divider()

            // Release notes
            ScrollView {
                Text(info.patchNotes)
                    .font(.body)
                    .padding(.horizontal)
            }
            .frame(maxHeight: 150)

            // Progress / Actions
            if manager.isUpdating {
                VStack(spacing: 8) {
                    if manager.downloadProgress < 1.0 {
                        ProgressView(value: manager.downloadProgress)
                            .progressViewStyle(.linear)
                        Text(String(format: "%@", manager.status))
                            .font(.caption)
                    } else {
                        ProgressView("Installing…")
                            .progressViewStyle(.circular)
                    }
                }
                .padding(.top)
            } else {
                HStack(spacing: 20) {
                    Button(action: onCancel) {
                        Label("Later", systemImage: "xmark")
                    }
                    Spacer()
                    Button(action: onInstall) {
                        Label("Update Now", systemImage: "arrow.down.circle.fill")
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding(.top)
            }
        }
        .padding()
        .frame(width: 420)
        .alert(
            "Installation Failed",
            isPresented: Binding(
                get: { !manager.installSucceeded && !manager.isUpdating && manager.status.hasPrefix("❌") },
                set: { _ in }
            ),
            actions: {
                Button("Retry") { onInstall() }
                Button("Cancel", role: .cancel) { onCancel() }
            },
            message: {
                Text(manager.status)
            }
        )
    }
}
