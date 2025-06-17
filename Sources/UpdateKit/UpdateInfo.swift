//
//  UpdateInfo.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import Foundation

public struct UpdateInfo {
    public let version: String
    public let downloadURL: URL
    public let patchNotes: String

    // ✅ Add this public initializer:
    public init(version: String, downloadURL: URL, patchNotes: String) {
        self.version = version
        self.downloadURL = downloadURL
        self.patchNotes = patchNotes
    }
}
