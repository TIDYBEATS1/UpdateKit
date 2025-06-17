//
//  UpdatePromptView.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import SwiftUI

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

            Text("What’s New")
                .font(.headline)

            ScrollView {
                Text(info.patchNotes)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
            }
            .frame(minHeight: 120)

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
    }
}