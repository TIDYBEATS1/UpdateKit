import SwiftUI

@available(macOS 12.0, *)
public struct UpdatePromptView: View {
    public let info: UpdateInfo
    public let onInstall: () -> Void
    public let onCancel: () -> Void

    public init(info: UpdateInfo, onInstall: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.info = info
        self.onInstall = onInstall
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("THIS IS THE UPDATE PROMPT")
                .font(.title)
            Button("Update Now", action: onInstall)
            Button("Later", action: onCancel)
        }
        .frame(width: 400, height: 250)
        .padding()
        .background(Color.white)
    }
}
