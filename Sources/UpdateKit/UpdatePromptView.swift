import SwiftUI

public struct UpdatePromptView: View {
    public let info: UpdateInfo
    public let onInstall: () -> Void
    public let onCancel: () -> Void

    @ObservedObject private var manager = UpdateManager()

    public init(info: UpdateInfo, onInstall: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.info = info
        self.onInstall = onInstall
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: 24) {
            Text("🚀 New Update Available")
                .font(.title)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                Text("Version \(info.version)")
                    .font(.headline)

                ScrollView {
                    Text(info.patchNotes)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                .frame(height: 150)
            }

            if manager.isUpdating {
                if manager.downloadProgress < 1.0 {
                    VStack {
                        ProgressView(value: manager.downloadProgress)
                            .progressViewStyle(.linear)
                        Text(String(format: "Downloading… %.0f%%", manager.downloadProgress * 100))
                            .font(.caption)

                        if let size = manager.estimatedDownloadSizeMB {
                            Text("~\(String(format: "%.1f", size)) MB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    ProgressView("Installing…")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top)
                }

                if manager.installSucceeded == false {
                    Text("❌ Install failed. Please try again later.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top)
                }
            }

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                Button("Update Now", action: {
                    manager.estimateDownloadSize(from: info.downloadURL)
                    manager.startUpdate(from: info)
                    onInstall()
                })
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 480)
    }
}
