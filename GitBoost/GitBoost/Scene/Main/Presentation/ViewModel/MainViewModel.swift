//
//  MainViewModel.swift
//  GitBoost
//
//  Created by 강치우 on 9/22/24.
//

import SwiftUI
import MessageUI

final class MainViewModel: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var contributionsData: ContributionsData?
    @Published var additionalGitHubData: AdditionalGitHubData?
    @Published var errorMessage: String?
    
    @Published var followers: [UserInfo] = []
    @Published var following: [UserInfo] = []
    
    @Published var scrollViewOffset: CGFloat = 0
    
    @Published var showLogoutDialog = false
    @Published var showDeleteAccountDialog = false
    @Published var showScoreSheet = false
    
    // 메일 관련
    @Published var isShowingMailComposer = false
    @Published var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    @Published var githubScore: Int = 0
    // 차트에서 사용할 데이터
    @Published var totalCommitsScore: Double = 0
    @Published var starsScore: Double = 0
    @Published var prsScore: Double = 0
    @Published var contributedRepoScore: Double = 0
    @Published var consecutiveCommitsScore: Double = 0

    
    func fetchGitHubData() {
        // GitHub 프로필 데이터 가져오기
        LoginManager.shared.fetchUserInfo { result in
            switch result {
            case .success(let userInfo):
                DispatchQueue.main.async {
                    self.userInfo = userInfo
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        // GitHub 기여도 데이터 가져오기
        LoginManager.shared.fetchContributionsData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.contributionsData = data
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    print("Failed to fetch contributions data: \(error.localizedDescription)")
                }
            }
        }
        
        LoginManager.shared.fetchAdditionalGitHubData { result in
            switch result {
            case .success(let additionalData):
                DispatchQueue.main.async {
                    self.additionalGitHubData = additionalData
                    self.calculateGitHubScore()  // 점수 계산
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func calculateGitHubScore() {
        guard let additionalData = additionalGitHubData else {
            print("추가 GitHub 데이터가 없습니다.")
            return
        }
        
        // 각 항목의 데이터
        let totalCommits = additionalData.data.viewer.contributionsCollection.totalCommitContributions
        let totalStars = additionalData.data.viewer.repositories.nodes.reduce(0) { $0 + $1.stargazerCount }
        let totalPRs = additionalData.data.viewer.pullRequests.totalCount
        let contributedReposLastYear = additionalData.data.viewer.repositoriesContributedTo.totalCount
        let consecutiveCommits = calculateConsecutiveCommits(from: contributionsData!)

        // 각 항목의 점수를 계산한 후 반올림 처리
        self.totalCommitsScore = (Double(totalCommits) * 0.2).rounded() // 커밋 점수
        self.starsScore = Double(totalStars).rounded() // 받은 스타 점수
        self.prsScore = (Double(totalPRs) * 0.5).rounded() // PR 점수
        self.contributedRepoScore = (Double(contributedReposLastYear) * 1).rounded() // 기여 리포 점수
        self.consecutiveCommitsScore = (Double(consecutiveCommits) * 0.5).rounded() // 연속 커밋 점수

        print("총 커밋 수: \(totalCommits), 점수: \(totalCommitsScore)")
        print("받은 Stars 수: \(totalStars), 점수: \(starsScore)")
        print("총 PR 수: \(totalPRs), 점수: \(prsScore)")
        print("기여한 리포지토리 수 (지난 해): \(contributedReposLastYear), 점수: \(contributedRepoScore)")
        print("연속 커밋 일수: \(consecutiveCommits), 점수: \(consecutiveCommitsScore)")

        // 최종 점수 계산
        let totalScore = totalCommitsScore + starsScore + prsScore + contributedRepoScore + consecutiveCommitsScore
        self.githubScore = Int(totalScore)

        // 최종 점수 로그 출력
        print("최종 GitHub 점수 (반올림): \(self.githubScore)")
    }
    
    // 오늘 커밋 수
    func calculateTodayCommits(from contributionsData: ContributionsData) -> Int {
        let contributionDays = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.flatMap { $0.contributionDays }
        return contributionDays.last?.contributionCount ?? 0
    }

    // 이번 주 커밋 수
    func calculateThisWeekCommits(from contributionsData: ContributionsData) -> Int {
        let currentWeek = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.last
        return currentWeek?.contributionDays.reduce(0, { $0 + $1.contributionCount }) ?? 0
    }

    // 연속된 커밋 날짜
    func calculateConsecutiveCommits(from contributionsData: ContributionsData) -> Int {
        let calendar = Calendar.current
        var consecutiveCommits = 0
        var previousDate: Date?
        
        for week in contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.reversed() {
            for day in week.contributionDays.reversed() {
                if let currentDate = dateFormatter.date(from: day.date) {
                    if previousDate == nil {
                        if day.contributionCount > 0 {
                            consecutiveCommits += 1
                            previousDate = currentDate
                        }
                    } else {
                        let difference = calendar.dateComponents([.day], from: currentDate, to: previousDate!).day
                        if difference == 1 {
                            if day.contributionCount > 0 {
                                consecutiveCommits += 1
                                previousDate = currentDate
                            } else {
                                return consecutiveCommits
                            }
                        } else {
                            return consecutiveCommits
                        }
                    }
                }
            }
        }
        
        return consecutiveCommits
    }
    
    func logout() {
        print("로그아웃")
        LoginManager.shared.logout()
    }
    
    func deleteAccount() {
        print("탈퇴하기")
        LoginManager.shared.deleteAccount()
    }

    // 날짜 포맷터
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
