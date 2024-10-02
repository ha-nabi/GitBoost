//
//  Home.swift
//  GitBoost
//
//  Created by 강치우 on 9/19/24.
//

import Kingfisher
import MessageUI
import SwiftUI

struct Home: View {
    @EnvironmentObject var mainViewModel: MainViewModel
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
                            mainViewModel.showScoreSheet = true
                        } label: {
                            Text(AppLocalized.scoreCheck)
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
                        .sheet(isPresented: $mainViewModel.showScoreSheet) {
                            GitHubScoreView(
                                score: $mainViewModel.githubScore,
                                totalCommitsScore: mainViewModel.totalCommitsScore,
                                starsScore: mainViewModel.starsScore,
                                prsScore: mainViewModel.prsScore,
                                contributedRepoScore: mainViewModel.contributedRepoScore,
                                consecutiveCommitsScore: mainViewModel.consecutiveCommitsScore
                            )
                        }
                        .presentationDetents([ .medium, .large])
                        .presentationBackground(.thinMaterial)
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
                Task {
                    await mainViewModel.fetchGitHubData()
                }
                grassViewModel.fetchContributionsData()
            }
            .coordinateSpace(name: "SCROLL")
            .confirmationDialog(
                AppLocalized.Logout,
                isPresented: $mainViewModel.showLogoutDialog,
                titleVisibility: .visible,
                actions: {
                    Button(AppLocalized.Logout, role: .destructive) {
                        mainViewModel.logout()
                    }
                },
                message: {
                    Text(AppLocalized.logoutText)
                }
            )
            .confirmationDialog(
                AppLocalized.toLeave,
                isPresented: $mainViewModel.showDeleteAccountDialog,
                titleVisibility: .visible,
                actions: {
                    Button(AppLocalized.toLeave, role: .destructive) {
                        mainViewModel.deleteAccount()
                    }
                },
                message: {
                    Text(AppLocalized.toLeaveText)
                }
            )
            .onAppear {
                if mainViewModel.isLoggedIn {
                    Task {
                        await mainViewModel.fetchGitHubData()  // 로그인한 상태라면 데이터를 갱신
                    }
                }
            }
        }
        .navigationBarTitle(mainViewModel.scrollViewOffset > 100 ? "" : (mainViewModel.userInfo?.login.uppercased() ?? ""), displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("GitBoost")
                    .font(.title3)
                    .fontWeight(.bold)
                    .opacity(0.9)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Menu(AppLocalized.InformationText) {
                        NavigationLink {
                            WebView(url: URL(string: "https://kangciu.notion.site/GitBoost-109518c03e1e80c8b620e34b8cc13676?pvs=4")!)
                                .navigationTitle(AppLocalized.policyText)
                                .toolbarTitleDisplayMode(.inline)
                        } label: {
                            Label {
                                Text(AppLocalized.policyText)
                            } icon: {
                                Image(systemName: "doc.text.fill")
                            }
                        }
                        
                        NavigationLink {
                            WebView(url: URL(string: "https://kangciu.notion.site/GitBoost-39134425b4e8453bab23d0801a1e3415?pvs=4")!)
                                .navigationTitle(AppLocalized.termsText)
                                .toolbarTitleDisplayMode(.inline)
                        } label: {
                            Label {
                                Text(AppLocalized.termsText)
                            } icon: {
                                Image(systemName: "doc.text.magnifyingglass")
                            }
                        }
                    }
                    
                    Menu(AppLocalized.accountSettingText) {
                        Button {
                            mainViewModel.showLogoutDialog = true
                        } label: {
                            Label {
                                Text(AppLocalized.Logout)
                            } icon: {
                                Image(systemName: "door.left.hand.open")
                            }
                            
                        }
                        
                        Button {
                            mainViewModel.showDeleteAccountDialog = true
                        } label: {
                            Label {
                                Text(AppLocalized.toLeave)
                            } icon: {
                                Image(systemName: "trash.slash.fill")
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button {
                        mainViewModel.isShowingMailComposer = true
                    } label: {
                        Label {
                            Text(AppLocalized.feedbackText)
                        } icon: {
                            Image(systemName: "exclamationmark.bubble.fill")
                        }
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .opacity(0.9)
                }
                .sheet(isPresented: $mainViewModel.isShowingMailComposer) {
                    MailComposer(
                        result: $mainViewModel.mailResult,
                        recipientEmail: "a2849535@gmail.com",
                        subject: AppLocalized.mailSubject,
                        body: AppLocalized.mailBody
                    )
                }
            }
        }
    }
    
    // MARK: Artwork View
    @ViewBuilder
    func ArtWork() -> some View {
        let height = size.height * 0.45
        
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
