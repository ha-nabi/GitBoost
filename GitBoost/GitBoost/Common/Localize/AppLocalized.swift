//
//  AppLocalized.swift
//  GitBoost
//
//  Created by 강치우 on 9/24/24.
//

import Foundation
import SwiftUICore

enum AppLocalized {
    // MARK: Main
    static let scoreCheck: LocalizedStringKey = "활동 점수 확인"
    
    // MARK: Navigation, Menu
    static let Logout: LocalizedStringKey = "로그아웃"
    static let toLeave: LocalizedStringKey = "탈퇴하기"
    static let logoutText: LocalizedStringKey = "현재 계정에서 로그아웃 하시겠어요?"
    static let toLeaveText: LocalizedStringKey = "현재 계정에서 탈퇴 하시겠어요?"
    static let InformationText: LocalizedStringKey = "정보"
    static let policyText: LocalizedStringKey = "개인정보 처리 방침"
    static let termsText: LocalizedStringKey = "이용 약관"
    static let accountSettingText: LocalizedStringKey = "계정 설정"
    static let feedbackText: LocalizedStringKey = "피드백 제공"
    static let mailSubject: LocalizedStringKey = "GitBoost 피드백 문의"
    static let mailBody: LocalizedStringKey = "GitBoost에 대한 피드백을 남겨주세요."
    
    // MARK: Stats
    static let todayStat: LocalizedStringKey = "오늘"
    static let weekStat: LocalizedStringKey = "이번주"
    static let sequenceStat: LocalizedStringKey = "연속"
    
    // MARK: GithubScore
    static let totalCommitText: LocalizedStringKey = "총 커밋 점수"
    static let starText: LocalizedStringKey = "스타 리포지토리 점수"
    static let prText: LocalizedStringKey = "PR 점수"
    static let contributedText: LocalizedStringKey = "기여한 리포지토리 점수"
    static let SequenceText: LocalizedStringKey = "연속 커밋 점수"
    static let scoreResultText: LocalizedStringKey = "활동 점수 결과"
    static let dismissText: LocalizedStringKey = "닫기"
    
    // MARK: Onboarding
    static let page1Title: LocalizedStringKey = "나의 활동 점수 확인하기"
    static let page2Title: LocalizedStringKey = "간편하게 기록을 확인하기"
    static let page3Title: LocalizedStringKey = "GitBoost 시작하기"
    static let page1SubTitle: LocalizedStringKey = "활동을 분석하여\n나만의 점수를 제공합니다."
    static let page2SubTitle: LocalizedStringKey = "오늘, 이번 주, 그리고\n연속 커밋 기록을 제공합니다."
    static let page3SubTitle: LocalizedStringKey = "로그인하여 더 많은 기능을 이용하세요."
    static let githubLoginText: LocalizedStringKey = "GitHub 연동하기"
    static let nextText: LocalizedStringKey = "다음으로"
    
    // MARK: Notification
    static let commitReminderNotificationText = NSLocalizedString("오늘 커밋을 잊으신건 아닌가요?", comment: "Reminder to commit")
    static let setNotificationsText: LocalizedStringKey = "알림 설정"
    static let activationText: LocalizedStringKey = "활성화"
    static let deactivationText: LocalizedStringKey = "비활성화"
    
    // MARK: Settings
    static let settingText: LocalizedStringKey = "설정"
    static let rateText: LocalizedStringKey = "평가하기"
    static let rateSubText: LocalizedStringKey = "앱스토어에서 저희 서비스를 평가해 주세요."
    static let feedbackSubText: LocalizedStringKey = "제안이나 질문이 있으면 이메일로 보내주세요."
    
    
}
