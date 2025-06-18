import SwiftUI

public struct UpdatePromptView: View {
    public let info: UpdateInfo
    @ObservedObject public var manager: UpdateManager
    public let onInstall: () -> Void
    public let onCancel:  () -> Void
    @State private var showDetails = false

    // Convert Markdown into an AttributedString once
    private var releaseNotes: AttributedString {
        (try? AttributedString(markdown: info.patchNotes, options: .init(interpretedSyntax: .full))) ?? AttributedString(info.patchNotes)
    }

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
            // — Header
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

            // — Release notes section
            VStack(spacing: 8) {
                HStack {
                    Text("Release Notes")
                        .font(.headline)
                    Spacer()
                    Button {
                        withAnimation { showDetails.toggle() }
                    } label: {
                        Image(systemName: showDetails ? "chevron.down" : "chevron.right")
                        Text(showDetails ? "Hide Details" : "Show Details")
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                if showDetails {
                    ScrollView {
                        Text(releaseNotes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .frame(height: 200)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    .padding(.horizontal)
                }
            }
            .padding()

            Divider()

            // — Progress or buttons
            Group {
                if manager.isUpdating {
                    VStack(spacing: 8) {
                        if manager.downloadProgress < 1.0 {
                            ProgressView(value: manager.downloadProgress)
                                .progressViewStyle(.linear)
                            Text(manager.status)
                                .font(.caption)
                        } else {
                            ProgressView("Installing…")
                                .progressViewStyle(.circular)
                        }
                    }
                    .padding()
                } else {
                    HStack {
                        Spacer()
                        Button("Later", role: .cancel, action: onCancel)
                        Button("Update Now", action: onInstall)
                            .keyboardShortcut(.defaultAction)
                    }
                    .padding()
                }
            }
        }
        .frame(width: 450)
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
            message: { Text(manager.status) }
        )
    }
}
