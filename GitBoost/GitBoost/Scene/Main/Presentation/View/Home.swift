//
//  Home.swift
//  GitBoost
//
//  Created by 강치우 on 9/19/24.
//

import Kingfisher
import SwiftUI

struct Home: View {
    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var grassViewModel = GlassViewModel()
    
    var safeArea: EdgeInsets
    var size: CGSize
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ArtWork()
                    
                    GeometryReader { proxy in
                        Button {
                            
                        } label: {
                            Text("깃허브 점수 확인")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 100)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.white))
                                }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 50)
                    .padding(.top, -34)
                    .zIndex(1)
                    
                    if let contributionsData = mainViewModel.contributionsData {
                        StatsView(
                            todayCommits: mainViewModel.calculateTodayCommits(from: contributionsData),
                            thisWeekCommits: mainViewModel.calculateThisWeekCommits(from: contributionsData),
                            consecutiveCommits: mainViewModel.calculateConsecutiveCommits(from: contributionsData)
                        )
                        .padding(.vertical, 10)
                        .zIndex(0)
                    }
                    
                    Divider()
                        .padding(10)
                    
                    GrassView(viewModel: grassViewModel)
                        .padding(.top, 10)
                }
            }
            .refreshable {
                mainViewModel.fetchGitHubData()
                grassViewModel.fetchContributionsData()
            }
            .coordinateSpace(name: "SCROLL")
            .confirmationDialog(
                "로그아웃",
                isPresented: $mainViewModel.showLogoutDialog,
                titleVisibility: .visible,
                actions: {
                    Button("로그아웃", role: .destructive) {
                        mainViewModel.logout()
                    }
                },
                message: {
                    Text("현재 계정에서 로그아웃 하시겠어요?")
                }
            )
            .confirmationDialog(
                "탈퇴하기",
                isPresented: $mainViewModel.showDeleteAccountDialog,
                titleVisibility: .visible,
                actions: {
                    Button("탈퇴하기", role: .destructive) {
                        mainViewModel.deleteAccount()
                    }
                },
                message: {
                    Text("현재 계정에서 로그아웃 하시겠어요?")
                }
            )
            .onAppear {
                mainViewModel.fetchGitHubData()
            }
        }
        .navigationBarTitle(mainViewModel.scrollViewOffset > 100 ? "" : (mainViewModel.userInfo?.login.uppercased() ?? ""), displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("GitBoost")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Menu("계정 설정") {
                        Button {
                            mainViewModel.showLogoutDialog = true
                        } label: {
                            Label {
                                Text("로그아웃")
                            } icon: {
                                Image(systemName: "door.left.hand.open")
                            }
                            
                        }
                        
                        Button {
                            mainViewModel.showDeleteAccountDialog = true
                        } label: {
                            Label {
                                Text("탈퇴하기")
                            } icon: {
                                Image(systemName: "trash.slash.fill")
                            }
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        Label {
                            Text("피드백 제공")
                        } icon: {
                            Image(systemName: "exclamationmark.bubble.fill")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    // MARK: Artwork View
    @ViewBuilder
    func ArtWork() -> some View {
        let height = size.height * 0.4
        
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))
            
            if let userInfo = mainViewModel.userInfo {
                KFImage(URL(string: userInfo.avatar_url))
                    .resizable()
                    .cacheOriginalImage(false) // 캐시된 이미지 사용x
                    .forceRefresh() // 강제 새로고침
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
                    .clipped()
                    .overlay {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .black.opacity(0 - progress),
                                            .black.opacity(0.1 - progress),
                                            .black.opacity(0.3 - progress),
                                            .black.opacity(0.5 - progress),
                                            .black.opacity(0.8 - progress),
                                            .black.opacity(1),
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            VStack(spacing: 0) {
                                Text(userInfo.name ?? userInfo.login)
                                    .font(.system(size: 45))
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                
                                Text(userInfo.login.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                                    .onScrollViewOffsetChange { offset in
                                        mainViewModel.scrollViewOffset = offset
                                    }
                                
                                // 팔로워 및 팔로잉 수 표시
                                HStack {
                                    Label {
                                        Text("followers")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.gray)
                                    } icon: {
                                        Text("\(userInfo.followers)")
                                            .fontWeight(.bold)
                                    }
                                    
                                    Text("·")
                                        .fontWeight(.semibold)
                                    
                                    Label {
                                        Text("following")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.gray)
                                    } icon: {
                                        Text("\(userInfo.following)")
                                            .fontWeight(.bold)
                                    }
                                }
                                .font(.subheadline)
                                .padding(.top, 10)
                            }
                            .opacity(1 + (progress > 0 ? -progress : progress))
                            .padding(.bottom, 55)
                            .offset(y: minY < 0 ? minY : 0)
                        }
                    }
                    .offset(y: -minY)
            }
        }
        .frame(height: height + safeArea.top)
    }
}

extension View {
    func onScrollViewOffsetChange(action:@escaping (_ offset: CGFloat) -> ()) -> some View {
        self
            .background(
                GeometryReader { geometry in
                    Text("")
                        .preference(key: ScrollViewOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                }
            )
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                action(value)
            }
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
