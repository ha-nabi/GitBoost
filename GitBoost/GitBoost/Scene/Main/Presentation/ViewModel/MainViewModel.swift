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
    @Published var isNavigatingToSettings = false
    
    // 메일 관련
    @Published var showMailView = false
    @Published var showMailErrorAlert = false
    @Published var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    // 차트에서 사용할 데이터
    @Published var githubScore: Int = 0
    @Published var totalCommitsScore: Double = 0
    @Published var starsScore: Double = 0
    @Published var prsScore: Double = 0
    @Published var contributedRepoScore: Double = 0
    @Published var consecutiveCommitsScore: Double = 0
    
    // 로그인 상태 및 알림 관련
    @Published var isLoggedIn: Bool = false
    @Published var isDummyLoggedOut = false
    @Published var isDummyDeleted = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    // 알림 관련
    @Published var hasCommittedToday: Bool = false
    @Published var isNotificationsEnabled: Bool {
        didSet {
            if isNotificationsEnabled {
                // 알림을 켜면 알림 스케줄링
                NotificationManager.shared.scheduleCommitReminderNotification(atHour: 20)
            } else {
                // 알림을 끄면 모든 알림 취소
                NotificationManager.shared.removeScheduledNotifications()
            }
            // 상태 저장
            UserDefaults.standard.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
        }
    }
    
    private let loginManager: LoginManager
    
    init(loginManager: LoginManager = .shared) {
        self.loginManager = loginManager
        self.isNotificationsEnabled = UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
    }
    
    func fetchGitHubData() async {
        // GitHub 프로필 데이터 가져오기
        do {
            let userInfo = try await loginManager.fetchUserInfo()
            DispatchQueue.main.async {
                self.userInfo = userInfo
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        // GitHub 기여도 데이터 가져오기
        do {
            let contributionsData = try await loginManager.fetchContributionsData()
            DispatchQueue.main.async {
                self.contributionsData = contributionsData
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        // 추가 GitHub 데이터 가져오기
        do {
            let additionalGitHubData = try await loginManager.fetchAdditionalGitHubData()
            DispatchQueue.main.async {
                self.additionalGitHubData = additionalGitHubData
                self.calculateGitHubScore()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // 점수 계산
    func calculateGitHubScore() {
        guard let additionalData = additionalGitHubData,
              let contributionsData = contributionsData else {
            print("GitHub 데이터가 없습니다.")
            return
        }
        
        // 각 항목의 데이터
        let totalCommits = additionalData.data.viewer.contributionsCollection.totalCommitContributions
        let totalStars = additionalData.data.viewer.repositories.nodes.reduce(0) { $0 + $1.stargazerCount }
        let totalPRs = additionalData.data.viewer.pullRequests.totalCount
        let contributedReposLastYear = additionalData.data.viewer.repositoriesContributedTo.totalCount
        let consecutiveCommits = calculateConsecutiveCommits(from: contributionsData)
        
        // 각 항목의 점수를 계산한 후 반올림 처리
        self.totalCommitsScore = (Double(totalCommits) * 0.2).rounded()
        self.starsScore = Double(totalStars).rounded()
        self.prsScore = (Double(totalPRs) * 0.5).rounded()
        self.contributedRepoScore = Double(contributedReposLastYear).rounded()
        self.consecutiveCommitsScore = (Double(consecutiveCommits) * 0.5).rounded()
        
        // 로그 출력
        print("총 커밋 수: \(totalCommits), 점수: \(totalCommitsScore)")
        print("받은 Stars 수: \(totalStars), 점수: \(starsScore)")
        print("총 PR 수: \(totalPRs), 점수: \(prsScore)")
        print("기여한 리포지토리 수 (지난 해): \(contributedReposLastYear), 점수: \(contributedRepoScore)")
        print("연속 커밋 일수: \(consecutiveCommits), 점수: \(consecutiveCommitsScore)")
        
        // 최종 점수 계산
        let totalScore = totalCommitsScore + starsScore + prsScore + contributedRepoScore + consecutiveCommitsScore
        self.githubScore = Int(totalScore)
        
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
    
    // GitHub에서 오늘 커밋이 있는지 확인
    func checkTodaysCommits(from contributionsData: ContributionsData, in userTimeZone: TimeZone) -> Bool {
        guard let lastWeek = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.last else {
            print("기여 데이터를 찾을 수 없습니다.")
            return false
        }
        
        // 현재 날짜를 사용자 로컬 시간대로 가져옴
        let currentDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let formatter = DateFormatter()
        formatter.timeZone = userTimeZone // 사용자의 로컬 시간대 설정
        formatter.dateFormat = "yyyy-MM-dd"
        
        let todayDateString = formatter.string(from: currentDate!)
        
        print("오늘 날짜 (사용자 시간대 \(userTimeZone.identifier)): \(todayDateString)")
        
        // 마지막 주의 기여 날짜만 출력
        for day in lastWeek.contributionDays {
            print("기여 날짜: \(day.date), 커밋 수: \(day.contributionCount)")
        }
        
        // 오늘 날짜와 일치하는 날짜에 커밋이 있는지 확인
        let hasCommitted = lastWeek.contributionDays.contains { day in
            let isToday = day.date == todayDateString
            let hasCommits = day.contributionCount > 0
            if isToday {
                print("오늘 커밋 여부 확인: \(hasCommits)")
            }
            return isToday && hasCommits
        }
        
        return hasCommitted
    }
    
    func logout() {
        if LoginManager.shared.isLoggedIn {
            print("계정 로그아웃")
            loginManager.logout()
            isLoggedIn = false
        } else {
            print("더미데이터 로그아웃")
            isDummyLoggedOut = true
        }
    }
    
    func deleteAccount() {
        if LoginManager.shared.isLoggedIn {
            print("계정 탈퇴")
            Task {
                do {
                    try await loginManager.deleteAccount()
                    DispatchQueue.main.async {
                        self.isLoggedIn = false
                        self.clearUserData()
                    }
                } catch {
                    DispatchQueue.main.async {
                    }
                }
            }
        } else {
            print("더미데이터 탈퇴")
            isDummyDeleted = true
            clearUserData()
        }
    }
    
    func mailButtonTapped() {
        if MFMailComposeViewController.canSendMail() {
            showMailView = true
        } else {
            showMailErrorAlert = true
        }
    }
    
    private func clearUserData() {
        userInfo = nil
        contributionsData = nil
        additionalGitHubData = nil
        followers = []
        following = []
        githubScore = 0
        totalCommitsScore = 0
        starsScore = 0
        prsScore = 0
        contributedRepoScore = 0
        consecutiveCommitsScore = 0
    }
    
    // 날짜 포맷터
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // 더미 데이터 로드
    func loadDummyData() {
        self.userInfo = UserInfo(
            login: "code-king",
            avatar_url: "https://avatars.githubusercontent.com/u/182574809?v=4",
            name: "David",
            followers: 74,
            following: 65
        )
        
        self.contributionsData = ContributionsData(
            data: ViewerWrapper(
                viewer: Viewer(
                    contributionsCollection: ContributionsCollection(
                        contributionCalendar: ContributionCalendar(
                            weeks: [Week(contributionDays: [
                                ContributionDay(date: "2024-09-22", contributionCount: 5),
                                ContributionDay(date: "2024-09-21", contributionCount: 3),
                                ContributionDay(date: "2024-09-20", contributionCount: 10)
                            ])]
                        )
                    )
                )
            )
        )
        
        self.additionalGitHubData = AdditionalGitHubData(
            data: AdditionalViewerWrapper(
                viewer: AdditionalViewer(
                    contributionsCollection: AdditionalContributionsCollection(
                        totalCommitContributions: 500
                    ),
                    repositories: RepositoryList(
                        nodes: [Repository(stargazerCount: 150)]
                    ),
                    pullRequests: AdditionalPRInfo(totalCount: 10),
                    repositoriesContributedTo: AdditionalRepoInfo(totalCount: 5)
                )
            )
        )
        
        self.calculateGitHubScore()
    }
}
