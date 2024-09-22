//
//  UserInfo.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import Foundation

// 사용자 정보
struct UserInfo: Codable {
    let login: String
    let avatar_url: String
    let name: String?
    let followers: Int
    let following: Int

    enum CodingKeys: String, CodingKey {
        case login
        case avatar_url
        case name
        case followers
        case following
    }
}
