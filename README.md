# 🛠️ UpdateKit v1.0.0 – Patch Notes Released  
*Sparkle-inspired macOS update framework. Ultra-light, delivers .zip updates to ~/Downloads — no app replacement, no permissions, no code signing needed. Modern, sandbox-safe, dev-friendly.*

---

## 🚀 v1.0.0: The Launch Update  
UpdateKit debuts as a sleek, modern solution for macOS app updates. Lightweight, App Store-compliant, and user-controlled with a SwiftUI-powered experience.

### 🎉 New in v1.0.0  
- **Public Launch**: UpdateKit is live to supercharge your app updates!  
- **Safe Downloads**: .zip updates land in ~/Downloads, fully sandbox-compliant.  
- **SwiftUI Prompt**: Sparkle-style alert with version, patch notes, and “Update Now”/“Skip” buttons.  
- **Live Progress**: Real-time download status and progress bar.  
- **GitHub Releases Powered**: Auto-checks versions and fetches .zip files from your repo.  

### 🔑 Core Features  
- **User-Driven Updates**: No auto-installs — users decide when to update.  
- **App Store Ready**: Works with sandboxed, signed, or unsigned apps.  
- **Simple .zip Delivery**: Downloads updates via GitHub Releases.  
- **Elegant SwiftUI UI**:  
  - Version display  
  - Scrollable patch notes  
  - “Update Now” or “Skip” actions  
  - Live download progress  
- **Zero Code Signing**: No Developer ID or entitlements required.  
- **SwiftPM Integration**: Add it to your project in seconds.  

---

## 🛠 Get Started in 4 Steps  

### 1. 📦 Install via Swift Package Manager  
In `Package.swift`:  
```swift
.package(url: "https://github.com/TIDYBEATS1/UpdateKit.git", from: "1.0.0")

In Xcode: File > Add Package Dependency…
Enter: https://github.com/KIDYBEATS1/UpdateKit.TIDYBEATS1
2. 🔎 Check for Updates
Fetch the latest release and show the prompt:

Copy
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
Add a progress view for download feedback:

if updater.isUpdating {
    ProgressView(updater.status, value: updater.downloadProgress)
        .padding()
}

4. ✅ “Update Now” Flow
Downloads .zip to ~/Downloads.
No app changes or relaunches.
Users manually install the update.
No permissions or prompts needed.
🔒 Sandbox & Security
UpdateKit is built for compliance:

100% Sandboxed: No system folder access or Apple Events.
No Admin Prompts: Seamless user experience.
App Store Safe: Ideal for hardened runtime or Store apps.
📜 License
MIT © KIDYBEATS1

🔥 Why Choose UpdateKit?
UpdateKit is the hassle-free way to deliver macOS updates. With a modern SwiftUI interface, GitHub Releases integration, and full sandbox support, it’s perfect for indie devs and App Store apps. Keep your users updated without the complexity.

Start Now: github.com/KIDYBEATS1/UpdateKit

Improvements Made:

Tighter Prose: Shortened descriptions for impact while keeping all details.
Bolder Visuals: Used stronger headings and emojis for a dynamic look.
Developer Focus: Emphasized ease of use and App Store compatibility.
Streamlined Code: Aligned code formatting and renamed variables (e.g., showSheet to showPrompt) for clarity.
Action-Oriented: Added a direct call-to-action with the repo link.
Consistent Tone: Adopted a confident, energetic voice to engage devs.
