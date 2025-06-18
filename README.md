# 🛠️ UpdateKit – Patch Notes v1.0.0

**UpdateKit** is a lightweight, Sparkle-style update framework for macOS that downloads `.zip` updates directly into the user's **Downloads folder** — no app replacement, no permissions, no code signing required.

---

## 🚀 What's New in v1.0.0

- ✅ **Initial public release**
- 📥 Downloads updates to `~/Downloads` (safe & sandbox-friendly)
- 🔔 SwiftUI update prompt with version and patch notes
- 📊 Live download progress display with status
- 🌐 GitHub Releases integration (version check + zip asset support)

---

## ✨ Key Features

- ✅ Zero app replacement — user manually installs if desired
- 📁 Safe for App Store & sandboxed apps
- 📦 `.zip` update delivery (via GitHub Releases)
- 🔔 Sparkle-like SwiftUI prompt:
  - Version label
  - Scrollable patch notes
  - "Update Now" / "Cancel"
  - Live progress indicator
- 🔧 No code signing, Developer ID, or entitlements needed
- 📦 Full Swift Package Manager support

---

## 🔧 Developer Integration

Here’s how to use **UpdateKit** in your SwiftUI app:

### 1. 📦 Add via Swift Package Manager

In `Package.swift`:

```swift
.package(url: "https://github.com/TIDYBEATS1/UpdateKit.git", from: "1.0.0")

File > Add Packages…
Paste: https://github.com/TIDYBEATS1/UpdateKit.git

⸻

2. 🔍 Check for Updates

Use GitHubReleaseChecker to fetch the latest release:

import UpdateKit

@main
struct MyApp: App {
    @StateObject private var updater = UpdateManager()
    @State private var info: UpdateInfo?
    @State private var showSheet = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: checkForUpdates)
                .sheet(isPresented: $showSheet) {
                    if let info {
                        UpdatePromptView(
                            info: info,
                            manager: updater,
                            onInstall: {
                                updater.startUpdate(from: info)
                                showSheet = false
                            },
                            onCancel: { showSheet = false }
                        )
                    }
                }
        }
    }

    func checkForUpdates() {
        GitHubReleaseChecker.fetchLatestRelease(repo: "yourusername/YourAppRepo") { result in
            DispatchQueue.main.async {
                if let release = try? result.get() {
                    info = UpdateInfo(
                        version: release.version,
                        downloadURL: release.downloadURL,
                        patchNotes: release.patchNotes
                    )
                    showSheet = true
                }
            }
        }
    }
}


3. 📉 Show Progress (Optional)

Bind the UpdateManager in your UI:

if updater.isUpdating {
    ProgressView(updater.status, value: updater.downloadProgress)
        .padding()
}


4. ✅ What Happens on “Update Now”
	•	The .zip is downloaded into ~/Downloads
	•	Your app is not modified or moved
	•	User can manually install the new version
	•	No permissions, elevation, or relaunching required

⸻

🔐 Permissions & Sandboxing

UpdateKit works entirely within the sandbox:
	•	No admin prompts
	•	No app replacement
	•	No Apple Events or system folder writes

Perfect for:
	•	App Store submissions
	•	Hardened runtime apps
	•	Signed or unsigned apps

⸻

📄 License

MIT © TIDYBEATS1

⸻

This marks the beginning of a lightweight, privacy-respecting, and dev-friendly update system for macOS.

---
