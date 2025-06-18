🛠️ UpdateKit – Patch Notes v1.0.0

Lightweight, Sparkle-inspired macOS update framework. Effortlessly deliver .zip updates to ~/Downloads — no app replacement, no permissions, no code signing required.

🚀 Welcome to UpdateKit v1.0.0
The initial public release of UpdateKit brings a modern, sandbox-friendly approach to macOS app updates. Designed for simplicity and flexibility, it empowers developers to deliver updates seamlessly while respecting user control and App Store guidelines.

✨ What’s New in v1.0.0

Initial Public Release: UpdateKit is here, ready to streamline your app updates!
Safe & Simple Downloads: Updates land directly in ~/Downloads, keeping things sandbox-friendly.
Sleek SwiftUI Prompt: A modern, Sparkle-like update interface with version details, scrollable patch notes, and clear “Update Now” or “Cancel” options.
Live Progress Tracking: Real-time download progress with status updates for a smooth user experience.
GitHub Releases Integration: Seamlessly checks for versions and fetches .zip assets from GitHub Releases.
🔑 Key Features
No App Replacement: Users manually install updates, giving them full control.
App Store Ready: Fully compatible with sandboxed apps and App Store submission requirements.
Lightweight Delivery: Downloads .zip updates via GitHub Releases — no fuss, no complexity.
Sparkle-Like Experience: Elegant SwiftUI prompt includes:
Version number display
Scrollable patch notes
“Update Now” and “Cancel” buttons
Live progress indicator for downloads
No Code Signing Needed: Works without Developer ID, entitlements, or complex permissions.
Swift Package Manager Support: Easily integrate UpdateKit into your project.
🛠️ Developer Quick Start
Integrate UpdateKit into your SwiftUI app in just a few steps. Here’s how to get started:

1. 📦 Add UpdateKit via Swift Package Manager

In your Package.swift:

swift

Collapse

Wrap

Copy
.package(url: "https://github.com/TIDYBEATS1/UpdateKit.git", from: "1.0.0")
Or in Xcode:

Go to File > Add Packages…
Paste: https://github.com/TIDYBEATS1/UpdateKit.git
2. 🔍 Check for Updates

Use GitHubReleaseChecker to fetch the latest release and display the update prompt:

swift

Collapse

Wrap

Copy
import UpdateKit
import SwiftUI

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
                    if let info = info {
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
3. 📊 Display Download Progress (Optional)

Show real-time download feedback in your UI:

swift

Collapse

Wrap

Copy
if updater.isUpdating {
    ProgressView(updater.status, value: updater.downloadProgress)
        .padding()
}
4. ✅ What Happens on “Update Now”

The .zip update downloads to ~/Downloads.
Your app remains untouched — no replacement or relaunch required.
Users manually install the update at their convenience.
No permissions or admin prompts needed.
🔐 Sandbox & Permissions
UpdateKit is designed with privacy and compliance in mind:

Fully Sandboxed: Works seamlessly within macOS sandbox restrictions.
No Admin Prompts: No elevation or system folder access required.
App Store Friendly: Perfect for signed, unsigned, or hardened runtime apps.
No Apple Events: Keeps your app lightweight and secure.
📄 License
MIT License © TIDYBEATS1

🌟 Why UpdateKit?
UpdateKit is the lightweight, developer-friendly solution for delivering macOS app updates. By combining a modern SwiftUI interface, GitHub Releases integration, and full sandbox compliance, it’s the perfect choice for indie developers and App Store apps alike.

Get started today and keep your users up to date with ease!

👉 Repository: github.com/TIDYBEATS1/UpdateKit

Changes Made:

Improved Structure: Organized sections with clear headings and subheadings for better readability.
Polished Language: Used more engaging and professional phrasing while keeping it concise.
Enhanced Clarity: Simplified technical explanations and code examples for accessibility.
Visual Consistency: Standardized emoji usage and formatting for a cohesive look.
Added Appeal: Included a "Why UpdateKit?" section to highlight its value proposition.
Streamlined Code: Formatted code blocks for better readability and consistency.
Actionable Links: Added a direct link to the repository for easy access.
