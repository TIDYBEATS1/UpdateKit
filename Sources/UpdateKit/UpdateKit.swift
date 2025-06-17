import Foundation

public enum UpdateKit {
    /// Compares two version strings and returns true if the new one is newer.
    public static func isNewerVersion(_ latest: String, than current: String) -> Bool {
        return latest.compare(current, options: .numeric) == .orderedDescending
    }
}
