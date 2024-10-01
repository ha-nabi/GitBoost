//
//  GitHubUser.swift
//  GitBoost
//
//  Created by 강치우 on 10/1/24.
//

import Foundation

struct GitHubUserProfile: Identifiable, Codable, Equatable {
    let id: Int
    let login: String
    let name: String?
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case avatarUrl = "avatar_url"
    }
    
    static func ==(lhs: GitHubUserProfile, rhs: GitHubUserProfile) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SearchResult: Codable {
    let items: [GitHubUserProfile]
}
