//
//  InstallHelper.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import Foundation
import AppKit  // for NSAppleScript

public enum InstallHelper {
    /// Copies the app at `sourceURL` into `/Applications/` using an AppleScript
    /// admin-privilege prompt. Returns true if successful.
    @discardableResult
    public static func privilegedCopyToApplications(from sourceURL: URL) -> Bool {
        let destPath = "/Applications/\(sourceURL.lastPathComponent)"
        // Escape any single quotes in paths
        let src = sourceURL.path.replacingOccurrences(of: "'", with: "\\'")
        let dst = destPath.replacingOccurrences(of: "'", with: "\\'")
        
        let script = """
        do shell script "cp -R '\(src)' '\(dst)'" with administrator privileges
        """
        
        var errorInfo: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&errorInfo)
        }
        
        if let err = errorInfo {
            print("❌ Privileged copy failed: \(err)")
            return false
        } else {
            print("✅ Copied to /Applications via AppleScript")
            return true
        }
    }
}