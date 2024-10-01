//
//  SearchView.swift
//  GitBoost
//
//  Created by 강치우 on 9/29/24.
//

import SwiftUI
import Kingfisher

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isSearchFieldFocused: Bool = true
    
    var body: some View {
        VStack {
            if viewModel.searchQuery.isEmpty {
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
            } else if viewModel.userProfiles.isEmpty {
                ScrollView(.vertical) {
                    Divider()
                        .padding(.bottom, 250)
                    
                    VStack(alignment: .center) {
                        Text("검색 결과가 없습니다.")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.bottom)
            } else {
                VStack {
                    Divider()
                    
                    List {
                        Section {
                            ForEach(viewModel.userProfiles) { profile in
                                HStack {
                                    KFImage(URL(string: profile.avatarUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        if let name = profile.name, !name.isEmpty {
                                            Text(name) // name
                                                .font(.headline)
                                            
                                            Text(profile.login) // login
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        } else {
                                            Text(profile.login)
                                                .font(.headline)
                                        }
                                    }
                                    .padding(.leading, 8)
                                }
                                .onAppear {
                                    // 프로필 리스트의 끝에 도달하면 데이터 추가 요청
                                    if profile == viewModel.userProfiles.last {
                                        viewModel.fetchMoreUsers()
                                    }
                                }
                            }
                        } header: {
                            Text("검색된 사용자")
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
        .searchable(text: $viewModel.searchQuery,
                    isPresented: $isSearchFieldFocused,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "GitHub 사용자 검색")
    }
}
