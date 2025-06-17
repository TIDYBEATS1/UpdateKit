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
        VStack(alignment: .leading, spacing: 16) {
            Text("New Version \(info.version) Available")
                .font(.headline)

            ScrollView {
                Text(info.patchNotes)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .padding(.vertical, 8)

            if manager.isUpdating {
                ProgressView(manager.status, value: manager.downloadProgress)
                    .progressViewStyle(.linear)
                    .padding(.vertical, 8)
            }

            HStack {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .disabled(manager.isUpdating)

                Spacer()

                Button("Update Now") {
                    onInstall()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(manager.isUpdating)
            }
        }
        .padding()
        .frame(width: 480)
        .alert(
            "Installation Failed",
            isPresented: Binding(
                get: { !manager.installSucceeded && !manager.isUpdating && manager.status.hasPrefix("❌") },
                set: { _ in }
            ),
            actions: {
                Button("Retry") {
                    onInstall()
                }
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
            },
            message: {
                Text(manager.status)
            }
        )
    }
}
