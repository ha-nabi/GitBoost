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

// Contributions 데이터
struct ContributionsData: Codable {
    let data: Viewer
}

struct Viewer: Codable {
    let viewer: ContributionsCollection
}

struct ContributionsCollection: Codable {
    let contributionsCollection: ContributionCalendar
}

struct ContributionCalendar: Codable {
    let totalContributions: Int
    let totalCommitContributions: Int
    let weeks: [Week]
}

struct Week: Codable {
    let contributionDays: [ContributionDay]
}

struct ContributionDay: Codable {
    let date: String
    let contributionCount: Int
}
