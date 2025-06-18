🛠️ UpdateKit v1.0.0 – Patch Notes Released
Sparkle-inspired macOS update framework. Ultra-lightweight. Delivers `.zip` updates to `~/Downloads`. No app replacement, no permissions, no code signing. Modern, sandbox-safe, and dev-friendly.

🚀 v1.0.0: The Launch Update
UpdateKit debuts as a sleek, modern solution for macOS app updates. Lightweight, App Store-compliant, and user-controlled via a SwiftUI-powered interface.

🎉 New in v1.0.0
- ✅ Public Launch – UpdateKit is live and ready to power your updates.
- 📥 Safe Downloads – Drops `.zip` files into `~/Downloads`, fully sandbox-safe.
- 🔔 SwiftUI Prompt – Sparkle-style sheet with version info and patch notes.
- 📊 Live Progress – Displays download progress and status.
- 🌐 GitHub Releases Support – Auto-checks and fetches `.zip` updates from your repo.

🔑 Core Features
- 🙋‍♂️ User-Driven Updates – No auto-installs. User chooses when to update.
- 🛡️ App Store Friendly – Works with sandboxed, signed, or unsigned apps.
- 📦 Simple `.zip` Delivery – Pulls from GitHub Releases.
- 🎨 Elegant SwiftUI UI:
  - Version display
  - Scrollable patch notes
  - “Update Now” / “Skip” actions
  - Real-time progress bar
- 🧾 No Code Signing Needed – No Developer ID or entitlements required.
- ⚙️ Swift Package Manager Support – Integrate in seconds.

🛠 Getting Started – 4 Easy Steps

1. 📦 Install via Swift Package Manager
In Package.swift:
.package(url: "https://github.com/TIDYBEATS1/UpdateKit.git", from: "1.0.0")

In Xcode:
File → Add Package Dependency…
Paste: https://github.com/TIDYBEATS1/UpdateKit.git

2. 🔎 Check for Updates

import SwiftUI
import UpdateKit

@main
struct MyApp: App {
    @StateObject private var updater = UpdateManager()
    @State private var info: UpdateInfo?
    @State private var showPrompt = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: checkUpdates)
                .sheet(isPresented: $showPrompt) {
                    if let info = info {
                        UpdatePromptView(
                            info: info,
                            manager: updater,
                            onUpdate: {
                                updater.startUpdate(from: info)
                                showPrompt = false
                            },
                            onSkip: { showPrompt = false }
                        )
                    }
                }
        }
    }

    func checkUpdates() {
        GitHubReleaseChecker.fetchLatestRelease(repo: "yourusername/YourAppRepo") { result in
            DispatchQueue.main.async {
                if let release = try? result.get() {
                    info = UpdateInfo(
                        version: release.version,
                        downloadURL: release.downloadURL,
                        patchNotes: release.patchNotes
                    )
                    showPrompt = true
                }
            }
        }
    }
}

3. 📈 Show Progress (Optional)
if updater.isUpdating {
    ProgressView(updater.status, value: updater.downloadProgress)
        .progressViewStyle(.linear)
        .padding()
}

4. ✅ “Update Now” Flow
- 📥 `.zip` file is downloaded into `~/Downloads`
- 🛑 No app changes, replacements, or relaunches
- 🖱️ User manually installs the new version
- 🔐 No permissions or elevation required

🔒 Sandboxing & Security
UpdateKit is designed for maximum compatibility:
- ✅ 100% Sandboxed: No system access, no Apple Events
- 🚫 No Admin Prompts
- 🛡️ App Store Safe: Perfect for hardened runtime or store apps

📜 License
MIT License © TIDYBEATS1

🔥 Why Choose UpdateKit?
UpdateKit is the hassle-free way to ship macOS updates. With a clean SwiftUI interface, full sandbox support, and GitHub Releases integration, it’s perfect for indie developers, power users, and App Store submissions.

👉 Start now: https://github.com/TIDYBEATS1/UpdateKit
