//
//  Page.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

enum Page: String, CaseIterable {
    case page1 = "trophy.fill"
    case page2 = "gamecontroller.fill"
    case page3 = "link.icloud.fill"
    case page4 = "text.bubble.fill"
    
    var title: String {
        switch self {
        case .page1: return "깃허브 점수 확인하기"
        case .page2: return "커밋 챌린지에 도전하기"
        case .page3: return "간편하게 기록을 확인하기"
        case .page4: return "GitBoost 시작하기"
        }
    }
    
    var subTitle: String {
        switch self {
        case .page1: return "깃허브 활동을 분석하여\n나만의 점수를 제공합니다."
        case .page2: return "꾸준한 커밋으로\n깃허브 커밋 챌린지를 완수하세요."
        case .page3: return "오늘, 이번 주, 그리고\n연속 커밋 기록을 제공합니다."
        case .page4: return "로그인하여 더 많은 기능을 이용하세요."
        }
    }
    
    var index: CGFloat {
        switch self {
        case .page1: return 0
        case .page2: return 1
        case .page3: return 2
        case .page4: return 3
        }
    }
    
    var nextPage: Page {
        let index = Int(self.index) + 1
        return index < 4 ? Page.allCases[index] : self
    }
    
    var previousPage: Page {
        let index = Int(self.index) - 1
        return index >= 0 ? Page.allCases[index] : self
    }
}
