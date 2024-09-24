//
//  StatsView.swift
//  GitBoost
//
//  Created by 강치우 on 9/19/24.
//

import SwiftUI

struct StatsView: View {
    let todayCommits: Int
    let thisWeekCommits: Int
    let consecutiveCommits: Int
    
    var body: some View {
        Section {
            HStack {
                StatItemView(icon: "checkmark.circle.fill", value: todayCommits, label: AppLocalized.todayStat, color: .green)
                
                Divider()
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                
                StatItemView(icon: "calendar", value: thisWeekCommits, label: AppLocalized.weekStat, color: .blue)
                
                Divider()
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                
                StatItemView(icon: "flame.fill", value: consecutiveCommits, label: AppLocalized.sequenceStat, color: .red)
            }
        }
    }
}

struct StatItemView: View {
    let icon: String
    let value: Int
    let label: LocalizedStringKey
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)
            
            Text("\(value)")
                .fontWeight(.semibold)
            
            
            Text(label)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(Color(.systemGray))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}
