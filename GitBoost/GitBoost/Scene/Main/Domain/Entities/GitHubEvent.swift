//
//  GitHubEvent.swift
//  GitBoost
//
//  Created by 강치우 on 10/3/24.
//

import Foundation

struct GitHubEvent: Codable {
    let type: String
    let created_at: String
}
