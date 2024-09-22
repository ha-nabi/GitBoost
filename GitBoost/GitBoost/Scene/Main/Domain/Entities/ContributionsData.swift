//
//  ContributionsData.swift
//  GitBoost
//
//  Created by 강치우 on 9/22/24.
//

import Foundation

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
