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

struct ContributionsData: Codable {
    let data: ViewerWrapper
}

struct ViewerWrapper: Codable {
    let viewer: Viewer
}

struct Viewer: Codable {
    let contributionsCollection: ContributionsCollection
}

struct ContributionsCollection: Codable {
    let contributionCalendar: ContributionCalendar
}

struct ContributionCalendar: Codable {
    let weeks: [Week]
}

struct Week: Codable {
    let contributionDays: [ContributionDay]
}

struct ContributionDay: Codable {
    let date: String
    let contributionCount: Int
}
