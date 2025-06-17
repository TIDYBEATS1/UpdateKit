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
            ScrollView {
                Text(info.patchNotes)
                    .font(.body)
            }
            HStack {
                Button("Update Now", action: onInstall)
                Button("Cancel", role: .cancel, action: onCancel)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
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
