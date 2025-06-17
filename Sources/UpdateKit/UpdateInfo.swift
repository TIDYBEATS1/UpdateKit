//
//  UpdateInfo.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import Foundation

// In UpdateKit/Sources/UpdateKit/UpdateInfo.swift

public struct UpdateInfo: Identifiable {
  public let version:    String
  public let downloadURL: URL
  public let patchNotes: String

  public let id = UUID()    // ← for SwiftUI .sheet(item:)

  public init(version: String,
              downloadURL: URL,
              patchNotes: String)
  {
    self.version     = version
    self.downloadURL = downloadURL
    self.patchNotes  = patchNotes
  }
}
