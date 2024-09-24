//
//  Page.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

enum Page: String, CaseIterable {
    case page1 = "trophy.fill"
//    case page2 = "gamecontroller.fill"
    case page2 = "link.icloud.fill"
    case page3 = "text.bubble.fill"
    
    var title: LocalizedStringKey {
        switch self {
        case .page1: return AppLocalized.page1Title
//        case .page2: return "커밋 챌린지에 도전하기"
        case .page2: return AppLocalized.page2Title
        case .page3: return AppLocalized.page3Title
        }
    }
    
    var subTitle: LocalizedStringKey {
        switch self {
        case .page1: return AppLocalized.page1SubTitle
//        case .page2: return "꾸준한 커밋으로\n깃허브 커밋 챌린지를 완수하세요."
        case .page2: return AppLocalized.page2SubTitle
        case .page3: return AppLocalized.page3SubTitle
        }
    }
    
    var index: CGFloat {
        switch self {
        case .page1: return 0
        case .page2: return 1
        case .page3: return 2
//        case .page4: return 3
        }
    }
    
    var nextPage: Page {
        let index = Int(self.index) + 1
        return index < 3 ? Page.allCases[index] : self
    }
    
    var previousPage: Page {
        let index = Int(self.index) - 1
        return index >= 0 ? Page.allCases[index] : self
    }
}
