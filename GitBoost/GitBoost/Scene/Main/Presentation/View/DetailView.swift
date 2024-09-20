//
//  DetailView.swift
//  GitBoost
//
//  Created by 강치우 on 9/19/24.
//

import SwiftUI

struct DetailView: View {
    @State private var commitChallengeGoal: Int = 100
    @State private var commitChallengeProgress: Int = 50
    
    var progress: Double {
        return Double(commitChallengeProgress) / Double(commitChallengeGoal)
    }
    
    var body: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                    Text("0개")
                        .fontWeight(.semibold)
                    Text("오늘")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemGray))
                }
                
                Divider()
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                
                VStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color(.systemBlue))
                        .font(.title2)
                    Text("4개")
                        .fontWeight(.semibold)
                    Text("이번주")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemGray))
                }
                
                Divider()
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                
                VStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color(.systemRed))
                        .font(.title2)
                    Text("423일")
                        .fontWeight(.semibold)
                    Text("연속")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemGray))
                }
                
                Spacer()
            }
        }
        .padding(.top)
        
        Divider()
        
        GrassView()
        
        Divider()
        
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Commit Challenge")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("\(commitChallengeProgress)")
                        .font(.title)
                        .fontWeight(.medium)
                    +
                    Text("/\(commitChallengeGoal)")
                }
                .fontWeight(.medium)
                
                Spacer()
                
                // 커스텀 원형 진행률 뷰
                CircularProgressView(progress: progress)
                    .padding(.horizontal)
            }
            .padding([.horizontal, .bottom])
        }
    }
}

#Preview {
    ContentView()
}
