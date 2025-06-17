import SwiftUI

#if os(macOS)
import AppKit
let backgroundColor = Color(nsColor: NSColor.windowBackgroundColor)
#else
import UIKit
let backgroundColor = Color(UIColor.systemBackground)
#endif

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
        VStack(alignment: .leading, spacing: 20) {
            Text("🆕 New Version Available")
                .font(.title2)
                .bold()

            Text("Version \(info.version)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("What’s New:")
                .font(.headline)

            ScrollView {
                Text(info.patchNotes)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(minHeight: 100)

            HStack {
                Spacer()
                Button("Later", action: onCancel)
                Button("Update Now", action: onInstall)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 500)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 20)
    }
}
