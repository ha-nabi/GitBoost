//
//  GitHubStats.swift
//  GitBoost
//
//  Created by 강치우 on 9/22/24.
//

import Foundation

struct AdditionalGitHubData: Codable {
    let data: AdditionalViewerWrapper
}

struct AdditionalViewerWrapper: Codable {
    let viewer: AdditionalViewer
}

struct AdditionalViewer: Codable {
    let contributionsCollection: AdditionalContributionsCollection
    let repositories: RepositoryList
    let pullRequests: AdditionalPRInfo
    let repositoriesContributedTo: AdditionalRepoInfo
}

struct AdditionalContributionsCollection: Codable {
    let totalCommitContributions: Int
}

struct RepositoryList: Codable {
    let nodes: [Repository]
}

struct Repository: Codable {
    let stargazerCount: Int // 레포지토리에서 받은 star 수
}

struct AdditionalRepoInfo: Codable {
    let totalCount: Int
}

struct AdditionalPRInfo: Codable {
    let totalCount: Int
}
