//
//  GitHubRelease.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import Foundation

public struct GitHubRelease {
    public let version: String
    public let patchNotes: String
    public let downloadURL: URL
}

public enum GitHubReleaseChecker {
    public static func fetchLatestRelease(
        repo: String, // e.g. "TIDYBEATS1/PS5NorMacApp"
        completion: @escaping (Result<GitHubRelease, Error>) -> Void
    ) {
        let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest")!

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let version = json["tag_name"] as? String,
                let notes = json["body"] as? String,
                let assets = json["assets"] as? [[String: Any]],
                let firstAsset = assets.first,
                let urlString = firstAsset["browser_download_url"] as? String,
                let downloadURL = URL(string: urlString)
            else {
                completion(.failure(NSError(domain: "GitHubParseError", code: -1)))
                return
            }

            let release = GitHubRelease(version: version, patchNotes: notes, downloadURL: downloadURL)
            completion(.success(release))
        }.resume()
    }
}