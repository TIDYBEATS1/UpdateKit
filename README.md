# 📝 Patch Notes – UpdateKit v1.0.0

> First release of **UpdateKit** — a lightweight update framework for macOS apps that **downloads new versions directly to the user’s Downloads folder**. No code signing, no permissions, no app replacement.

---

## ✨ New Features

- 📥 **One-Click Downloads**  
  Automatically downloads `.zip` update files from GitHub to the user's Downloads folder.

- 🔔 **Update Prompt Sheet**  
  SwiftUI-powered modal showing version info and patch notes, with “Update Now” and “Cancel” buttons.

- 📊 **Live Progress View**  
  Linear progress bar with live download status and completion message.

- 🔗 **GitHub Releases Integration**  
  Fetches latest version, patch notes, and asset URL from your public GitHub repo.

---

## 🚫 What's Not Included (by design)

- ❌ No app replacement
- ❌ No admin prompts
- ❌ No sandbox exceptions required
- ❌ No Developer ID or signed zip files required

Just a clean `.zip` download to the Downloads folder, ready for users to unzip and move manually.

---

## 💻 Dev Features

- ✅ Swift Package Manager compatible
- ✅ Fully sandbox-safe
- ✅ No write access to `/Applications` required
- ✅ Easily integrated into SwiftUI apps

---

## 🔧 API Summary

- `UpdateManager`: handles checking for updates and downloading
- `UpdateInfo`: stores version, download URL, patch notes
- `UpdatePromptView`: SwiftUI sheet displaying update info and progress

---

## 📄 License

MIT License © TIDYBEATS1
