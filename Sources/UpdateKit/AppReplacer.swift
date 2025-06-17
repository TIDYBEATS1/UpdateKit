//
//  AppReplacer.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import Foundation
import AppKit

public enum AppReplacer {
    /// Replaces the current running app with the one at the given URL.
    public static func replaceCurrentApp(with newAppURL: URL) {
        guard let currentAppPath = Bundle.main.bundleURL.standardized.path.removingPercentEncoding else {
            print("❌ Could not determine current app path.")
            return
        }

        let newAppPath = newAppURL.standardized.path

        print("🛠 Replacing app at \(currentAppPath) with new app from \(newAppPath)")

        // Step 1: Launch a helper shell script (background process)
        let script = """
        sleep 1
        rm -rf "\(currentAppPath)"
        mv "\(newAppPath)" "\(currentAppPath)"
        open "\(currentAppPath)"
        """

        let tempScriptURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("app_replace.sh")
        do {
            try script.write(to: tempScriptURL, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tempScriptURL.path)
        } catch {
            print("❌ Failed to write launch script: \(error.localizedDescription)")
            return
        }

        // Step 2: Run the script
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = [tempScriptURL.path]
        do {
            try task.run()
        } catch {
            print("❌ Failed to run update script: \(error.localizedDescription)")
        }

        // Step 3: Quit current app
        NSApp.terminate(nil)
    }
}