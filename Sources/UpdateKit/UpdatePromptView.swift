import SwiftUI

public struct UpdatePromptView: View {
    public let info: UpdateInfo
    @ObservedObject public var manager: UpdateManager
    public let onInstall: () -> Void
    public let onCancel:  () -> Void
    @State private var showDetails = false    // Sparkle-style details toggle

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
        VStack(spacing: 0) {
            // MARK: Header
            HStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading) {
                    Text("Version \(info.version) Available")
                        .font(.title2).bold()
                    Text("A new update is ready.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            Divider()

            // MARK: Main content
            VStack(spacing: 16) {
                // Release notes title + toggle
                HStack {
                    Text("Release Notes")
                        .font(.headline)
                    Spacer()
                    Button(action: { withAnimation { showDetails.toggle() } }) {
                        HStack(spacing: 4) {
                            Image(systemName: showDetails ? "chevron.down" : "chevron.right")
                            Text("Show Details")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Collapsible release notes pane
                if showDetails {
                    ScrollView {
                        Text(info.patchNotes)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 180)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    .padding(.horizontal)
                }

                // Progress or action buttons
                if manager.isUpdating {
                    VStack(spacing: 8) {
                        if manager.downloadProgress < 1.0 {
                            ProgressView(value: manager.downloadProgress)
                                .progressViewStyle(.linear)
                                .frame(width: 360)
                            Text(manager.status)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            ProgressView("Installing…")
                                .progressViewStyle(.circular)
                        }
                    }
                    .padding(.top)
                } else {
                    HStack {
                        Spacer()
                        Button("Later", role: .cancel, action: onCancel)
                        Button(action: onInstall) {
                            Text("Update Now")
                                .frame(minWidth: 80)
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                    .padding(.top)
                }
            }
            .padding()
            .frame(width: 420)
        }
        // MARK: Error alert
        .alert(
            "Installation Failed",
            isPresented: Binding(
                get: {
                    !manager.installSucceeded
                        && !manager.isUpdating
                        && manager.status.hasPrefix("❌")
                },
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
