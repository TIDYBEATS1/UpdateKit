//
//  FirebaseService.swift
//  UpdateKit
//
//  Created by Sam Stanwell on 17/06/2025.
//


import FirebaseRemoteConfig
import Foundation

struct FirebaseService {
    static func fetchUpdateInfo(completion: @escaping (UpdateInfo?) -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetchAndActivate { _, _ in
            guard
                let version = remoteConfig["latest_version"].stringValue,
                let urlString = remoteConfig["update_url"].stringValue,
                let patchNotes = remoteConfig["patch_notes"].stringValue,
                let url = URL(string: urlString)
            else {
                completion(nil)
                return
            }

            completion(UpdateInfo(version: version, downloadURL: url, patchNotes: patchNotes))
        }
    }
}