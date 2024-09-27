//
//  Contribution.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import Foundation

struct Contribution: Identifiable {
    let date: Date
    let count: Int

    var id: Date {
        date
    }
}

extension Contribution {
    static func generate() -> [Contribution] {
        var contributions: [Contribution] = []
        let toDate = Date.now
        let fromDate = Calendar.current.date(byAdding: .month, value: -5, to: toDate)!  // 최근 5개월 데이터 생성

        var currentDate = fromDate

        while currentDate <= toDate {
            let contribution = Contribution(date: currentDate, count: .random(in: 0...10))  // 0~10의 랜덤 기여도 생성
            contributions.append(contribution)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!  // 하루씩 더해가며 데이터 생성
        }

        return contributions
    }
}
