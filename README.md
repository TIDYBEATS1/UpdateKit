<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>UpdateKit v1.0.0 – Patch Notes</title>
  <style>
    body {
      font-family: system-ui, -apple-system, sans-serif;
      line-height: 1.6;
      padding: 2rem;
      background: #f9f9fb;
      color: #333;
      max-width: 800px;
      margin: auto;
    }
    code {
      background: #f1f1f1;
      padding: 2px 6px;
      border-radius: 4px;
      font-family: monospace;
    }
    pre {
      background: #f1f1f1;
      padding: 1rem;
      overflow: auto;
      border-radius: 6px;
    }
    h1, h2, h3 {
      margin-top: 2rem;
    }
    ul {
      padding-left: 1.5rem;
    }
  </style>
</head>
<body>

<h1>🛠️ UpdateKit v1.0.0 – Patch Notes Release</h1>
<p><em>Sparkle-inspired macOS update framework. Ultra-lightweight. Delivers <code>.zip</code> updates to <code>~/Downloads</code>. No app replacement, no permissions, no code signing. Modern, sandbox-safe, and dev-friendly.</em></p>

<h2>🚀 v1.0.0: The Launch Update</h2>
<p>UpdateKit debuts as a sleek, modern solution for macOS app updates. Lightweight, App Store-compliant, and user-controlled via a SwiftUI-powered interface.</p>

<h3>🎉 New in v1.0.0</h3>
<ul>
  <li>✅ <strong>Public Launch</strong> – UpdateKit is live and ready to power your updates.</li>
  <li>📥 <strong>Safe Downloads</strong> – Drops <code>.zip</code> files into <code>~/Downloads</code>, fully sandbox-safe.</li>
  <li>🔔 <strong>SwiftUI Prompt</strong> – Sparkle-style sheet with version info and patch notes.</li>
  <li>📊 <strong>Live Progress</strong> – Displays download progress and status.</li>
  <li>🌐 <strong>GitHub Releases Support</strong> – Auto-checks and fetches <code>.zip</code> updates from your repo.</li>
</ul>

<h3>🔑 Core Features</h3>
<ul>
  <li>🙋‍♂️ <strong>User-Driven Updates</strong> – No auto-installs. User chooses when to update.</li>
  <li>🛡️ <strong>App Store Friendly</strong> – Works with sandboxed, signed, or unsigned apps.</li>
  <li>📦 <strong>Simple <code>.zip</code> Delivery</strong> – Pulls from GitHub Releases.</li>
  <li>🎨 <strong>Elegant SwiftUI UI:</strong>
    <ul>
      <li>Version display</li>
      <li>Scrollable patch notes</li>
      <li>“Update Now” / “Skip” actions</li>
      <li>Real-time progress bar</li>
    </ul>
  </li>
  <li>🧾 <strong>No Code Signing Needed</strong> – No Developer ID or entitlements required.</li>
  <li>⚙️ <strong>Swift Package Manager Support</strong> – Integrate in seconds.</li>
</ul>

<h2>🛠 Getting Started – 4 Easy Steps</h2>

<h3>1. 📦 Install via Swift Package Manager</h3>
<pre><code>.package(url: "https://github.com/TIDYBEATS1/UpdateKit.git", from: "1.0.0")</code></pre>
<p><strong>In Xcode:</strong> File → Add Package Dependency…<br>
Paste: <code>https://github.com/TIDYBEATS1/UpdateKit.git</code></p>

<h3>2. 🔎 Check for Updates</h3>
<pre><code>import SwiftUI
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
</code></pre>

<h3>3. 📈 Show Progress (Optional)</h3>
<pre><code>if updater.isUpdating {
    ProgressView(updater.status, value: updater.downloadProgress)
        .progressViewStyle(.linear)
        .padding()
}
</code></pre>

<h3>4. ✅ “Update Now” Flow</h3>
<ul>
  <li>📥 <code>.zip</code> file is downloaded into <code>~/Downloads</code></li>
  <li>🛑 No app changes, replacements, or relaunches</li>
  <li>🖱️ User manually installs the new version</li>
  <li>🔐 No permissions or elevation required</li>
</ul>

<h2>🔒 Sandboxing & Security</h2>
<ul>
  <li>✅ <strong>100% Sandboxed</strong>: No system access, no Apple Events</li>
  <li>🚫 <strong>No Admin Prompts</strong></li>
  <li>🛡️ <strong>App Store Safe</strong>: Perfect for hardened runtime or store apps</li>
</ul>

<h2>📜 License</h2>
<p><strong>MIT License © TIDYBEATS1</strong></p>

<h2>🔥 Why Choose UpdateKit?</h2>
<p>UpdateKit is the hassle-free way to ship macOS updates. With a clean SwiftUI interface, full sandbox support, and GitHub Releases integration, it’s perfect for indie developers, power users, and App Store submissions.</p>

<p>👉 <a href="https://github.com/TIDYBEATS1/UpdateKit">Start now: github.com/TIDYBEATS1/UpdateKit</a></p>

</body>
</html>
