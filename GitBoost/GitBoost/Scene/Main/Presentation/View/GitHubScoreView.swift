//
//  GitHubScoreView.swift
//  GitBoost
//
//  Created by 강치우 on 9/22/24.
//

import SwiftUI

struct GitHubScoreView: View {
    @Binding var score: Int
    let totalCommitsScore: Double
    let starsScore: Double
    let prsScore: Double
    let contributedRepoScore: Double
    let consecutiveCommitsScore: Double
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // 점수 섹션
                Section(header: Text("GitHub Score")) {
                    Text("\(score)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(score >= 100 ? .green : .red)
                    +
                    Text(" Score")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Score Chart")) {
                    ScoreBarChart(data: [
                        ChartData(label: "Commits", value: totalCommitsScore),
                        ChartData(label: "Stars", value: starsScore),
                        ChartData(label: "PRs", value: prsScore),
                        ChartData(label: "Repo", value: contributedRepoScore),
                        ChartData(label: "Sequence", value: consecutiveCommitsScore)
                    ])
                    .frame(height: 200)
                }
                
                // 세부 점수 섹션
                Section(header: Text("Detail Stats")) {
                    DetailScoreRow(title: "총 커밋 점수", subTitle: "Total Commits", score: totalCommitsScore)
                    DetailScoreRow(title: "스타 리포지토리 점수", subTitle: "Total Stars Earned", score: starsScore)
                    DetailScoreRow(title: "PR 점수", subTitle: "Total PRs", score: prsScore)
                    DetailScoreRow(title: "기여한 리포지토리 점수", subTitle: "Contributed Repo Score", score: contributedRepoScore)
                    DetailScoreRow(title: "연속 커밋 점수", subTitle: "Sequence Commit Score", score: consecutiveCommitsScore)
                }
            }
            .listStyle(.grouped)
            .navigationTitle("깃허브 점수 결과")
            .toolbarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("닫기")
                    }
                }
            }
        }
    }
}

struct DetailScoreRow: View {
    let title: String
    let subTitle: String
    let score: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                
                Text(subTitle)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Text(String(format: "%.f", score))
                .font(.body)
                .fontWeight(.bold)
        }
        .padding(.vertical, 5)
    }
}
