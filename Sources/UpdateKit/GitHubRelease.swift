//
//  GitHubRelease.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//

import Foundation

public struct GitHubRelease: Decodable {
    // JSON fields from GitHub’s API:
    public let tag_name: String
    public let html_url: URL
    public let body: String?
    public let assets: [Asset]

    public struct Asset: Decodable {
        public let browser_download_url: URL
    }

    // MARK: – Computed “friendly” properties for your UI:

    /// e.g. "v1.2.3"
    public var version: String { tag_name }

    /// first asset’s URL, or fallback to the HTML page
    public var downloadURL: URL {
        assets.first?.browser_download_url ?? html_url
    }

    /// release notes text
    public var patchNotes: String {
        body ?? "No release notes."
    }
}

public enum GitHubReleaseChecker {
    /// Fetches `https://api.github.com/repos/{owner}/{repo}/releases/latest`
    /// and decodes it into our `GitHubRelease` model.
    public static func fetchLatestRelease(
        repo: String,
        completion: @escaping (Result<GitHubRelease, Error>) -> Void
    ) {
        let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest")!
        var req = URLRequest(url: url)
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1)))
                return
            }
            do {
                // JSONDecoder knows how to map tag_name → tag_name, etc.
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                completion(.success(release))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
