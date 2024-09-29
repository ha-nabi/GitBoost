//
//  SearchView.swift
//  GitBoost
//
//  Created by 강치우 on 9/29/24.
//

import Kingfisher
import SwiftUI

struct SearchView: View {
    @State private var searchQuery: String = ""
    @State private var isSearchFieldFocused: Bool = true
    
    var body: some View {
        VStack {
            if searchQuery.isEmpty {
                ScrollView(.vertical) {
                    Divider()
                        .padding(.bottom, 250)
                    
                    VStack(alignment: .center, spacing: 12) {
                        Text("사용자를 찾아보세요.")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("모든 GitHub에서 사용자의 이름, 아이디를 검색합니다.")
                            .font(.callout)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.bottom)
            } else {
                VStack {
                    Divider()
                    
                    List {
                        Section {
                            HStack {
                                Image("im1")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("치우")
                                        .font(.headline)
                                    
                                    Text("ha-nabi")
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                                .padding(.leading, 8)
                            }
                        } header: {
                            Text("사용자")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    .listStyle(.grouped)
                }
            }
        }
        .navigationTitle("탐색")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchQuery,
                    isPresented: $isSearchFieldFocused,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "GitHub 사용자 검색")
    }
}
