//
//  Home.swift
//  GitBoost
//
//  Created by 강치우 on 9/19/24.
//

import Kingfisher
import SwiftUI

struct Home: View {
    var safeArea: EdgeInsets
    var size: CGSize
    
    @State private var scrollViewOffset: CGFloat = 0
    
    @State private var showLogoutDialog = false
    @State private var showDeleteAccountDialog = false
    
    @State private var userInfo: UserInfo?
    @State private var contributionsData: ContributionsData?
    @State private var followers: [UserInfo] = []
    @State private var following: [UserInfo] = []
    @State private var errorMessage: String?
    
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
                    
                    DetailView()
                        .padding(.vertical)
                        .zIndex(0)
                }
            }
            .coordinateSpace(name: "SCROLL")
            .confirmationDialog(
                "로그아웃",
                isPresented: $showLogoutDialog,
                titleVisibility: .visible,
                actions: {
                    Button("로그아웃", role: .destructive) {
                        logout()
                    }
                },
                message: {
                    Text("현재 계정에서 로그아웃 하시겠어요?")
                }
            )
            .confirmationDialog(
                "탈퇴하기",
                isPresented: $showDeleteAccountDialog,
                titleVisibility: .visible,
                actions: {
                    Button("탈퇴하기", role: .destructive) {
                        deleteAccount()
                    }
                },
                message: {
                    Text("현재 계정에서 로그아웃 하시겠어요?")
                }
            )
            .onAppear {
                fetchGitHubData()
            }
        }
        .navigationBarTitle(scrollViewOffset > 100 ? "" : (userInfo?.login.uppercased() ?? ""), displayMode: .inline)
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
                            showLogoutDialog = true
                        } label: {
                            Label {
                                Text("로그아웃")
                            } icon: {
                                Image(systemName: "door.left.hand.open")
                            }
                            
                        }
                        
                        Button {
                            showDeleteAccountDialog = true
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
        let height = size.height * 0.8
        
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))
            
            if let userInfo = userInfo {
                KFImage(URL(string: userInfo.avatar_url))
                    .resizable()
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
                                        scrollViewOffset = offset
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
    
    // Actions
    func logout() {
        print("로그아웃")
        LoginManager.shared.logout()
    }

    func deleteAccount() {
        print("탈퇴하기")
        LoginManager.shared.deleteAccount()
    }
    
    func fetchGitHubData() {
        // Fetch user info
        LoginManager.shared.fetchUserInfo { result in
            switch result {
            case .success(let userInfo):
                DispatchQueue.main.async {
                    self.userInfo = userInfo
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }

        // Fetch contributions data
        LoginManager.shared.fetchContributionsData { result in
            switch result {
            case .success(let contributionsData):
                DispatchQueue.main.async {
                    self.contributionsData = contributionsData
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 오늘 커밋 갯수 계산
    func calculateTodayCommits(from data: ContributionsData) -> Int {
        let today = DateFormatter().string(from: Date())
        return data.data.viewer.contributionsCollection.weeks.flatMap { $0.contributionDays }
            .first(where: { $0.date == today })?.contributionCount ?? 0
    }

    // 이번 주 커밋 갯수 계산
    func calculateThisWeekCommits(from data: ContributionsData) -> Int {
        return data.data.viewer.contributionsCollection.weeks.flatMap { $0.contributionDays }
            .reduce(0) { $0 + $1.contributionCount }
    }

    // 연속 커밋 일수 계산
    func calculateConsecutiveCommits(from data: ContributionsData) -> Int {
        // Custom logic to calculate consecutive commit days
        return 0 // Placeholder, implement your logic here
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

#Preview {
    ContentView()
}
