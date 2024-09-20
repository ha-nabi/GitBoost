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
        let fromDate = Calendar.current.date(byAdding: .day, value: -60, to: toDate)!

        var currentDate = fromDate
        
        while currentDate <= toDate {
            let contribution = Contribution(date: currentDate, count: .random(in: 0...10))
            contributions.append(contribution)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return contributions
    }
}
