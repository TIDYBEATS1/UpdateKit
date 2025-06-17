// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public enum UpdateKit {
    
    /// Checks Firebase Remote Config for a newer version than the one provided.
    /// - Parameters:
    ///   - currentVersion: Your app's current version string (e.g., "1.0.0")
    ///   - completion: Returns an `UpdateInfo` if a newer version is found
    public static func checkForUpdates(currentVersion: String, completion: @escaping (UpdateInfo?) -> Void) {
        FirebaseService.fetchUpdateInfo { info in
            guard let info = info else {
                completion(nil)
                return
            }

            // Compare versions numerically
            let isNewer = info.version.compare(currentVersion, options: .numeric) == .orderedDescending
            completion(isNewer ? info : nil)
        }
    }
}
