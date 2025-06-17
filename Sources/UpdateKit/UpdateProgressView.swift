//
//  UpdateProgressView.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import SwiftUI

public struct UpdateProgressView: View {
    @ObservedObject var manager: UpdateManager

    public init(manager: UpdateManager) {
        self.manager = manager
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(manager.status)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)

            if manager.isUpdating {
                ProgressView()
            }
        }
        .padding()
        .frame(width: 300)
    }
}