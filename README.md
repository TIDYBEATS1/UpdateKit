# UpdateKit

**UpdateKit** is a modern, user‑friendly Sparkle®‑style update framework for macOS apps. It lets you:

- Check for new releases (e.g. GitHub Releases) or Firebase Remote Config
- Display patch notes and version info in a SwiftUI prompt
- Download `.zip` update packages with live progress
- Safely replace your running app (in‑place, user‑Applications folder, or with admin prompt)
- Auto‑relaunch the new build, with rollback on failure

All without requiring code signing, Sparkle frameworks, or a Developer ID.

---

## ✨ Features

- ✅ Zero code‑signing: no Developer ID needed
- ☁️ Firebase Remote Config support (host app provides JSON URL)
- 📦 Zip‑based downloads & unpacks
- 🔔 Sparkle‑style SwiftUI prompt view
- 📊 Live download progress & status messages
- 🔄 Three‑step install ladder:
  1. In‑place bundle replacement
  2. Copy to `~/Applications`
  3. Admin‑prompt fallback to `/Applications`
- 🔁 Automatic relaunch after install
- ⚠️ Safe rollback on errors
- 📦 Swift Package Manager support

---

## 📦 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
.package(
    url: "https://github.com/TIDYBEATS1/UpdateKit.git",
    from: "1.0.0"
)
```

Or in Xcode: **File > Swift Packages > Add Package Dependency…** and paste the GitHub URL.

---

## 🚀 Quick Start

### 1. Import & Initialize

In your App delegate or main SwiftUI `@main`:

```swift
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
        // Example: GitHub
        GitHubReleaseChecker.fetchLatestRelease(repo: "you/YourApp") { result in
            DispatchQueue.main.async {
                if let rel = try? result.get() {
                    info = UpdateInfo(
                        version: rel.version,
                        downloadURL: rel.downloadURL,
                        patchNotes: rel.patchNotes
                    )
                    showSheet = true
                }
            }
        }
    }
}
```

### 2. Bind Progress in Your UI

In your `ContentView` (or wherever):
```swift
if updater.isUpdating {
    ProgressView(updater.status, value: updater.downloadProgress)
        .progressViewStyle(.linear)
}
```

### 3. Relaunch & Rollback
The framework automatically shows an `NSAlert` on success to relaunch the app, or rolls back if installation fails.

---

## 🛠 API Reference

### `struct UpdateInfo`

Holds metadata for an update.
```swift
public struct UpdateInfo {
    public let version: String
    public let downloadURL: URL
    public let patchNotes: String
}
```

### `class UpdateManager: ObservableObject`

- `@Published var downloadProgress: Double`  (0.0–1.0)
- `@Published var status: String`             (human‑readable)
- `@Published var isUpdating: Bool`
- `func startUpdate(from info: UpdateInfo)`
- Automatically handles download, unzip, install, and relaunch.

### `struct UpdatePromptView: View`

A ready‑made SwiftUI sheet:
```swift
UpdatePromptView(
    info: UpdateInfo,
    manager: UpdateManager,
    onInstall: { /* call startUpdate */ },
    onCancel:  { /* dismiss sheet */ }
)
```
It displays:
- Version title
- Scrollable patch notes
- “Update Now” / “Cancel” buttons
- Live `ProgressView` & status
- Retry alert on failure

---

## 💡 Example Demo

See the `UpdateKitDemoApp` in this repo for a complete sample macOS app using UpdateKit.

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome! Please open issues or pull requests on GitHub.

---

## 📄 License

[MIT](LICENSE) © TIDYBEATS1
