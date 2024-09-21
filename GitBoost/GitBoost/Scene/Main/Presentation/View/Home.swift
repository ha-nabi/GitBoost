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
                    
                    if let contributionsData = contributionsData {
                        DetailView(
                            todayCommits: calculateTodayCommits(from: contributionsData),
                            thisWeekCommits: calculateThisWeekCommits(from: contributionsData),
                            consecutiveCommits: calculateConsecutiveCommits(from: contributionsData)
                        )
                        .padding(.vertical)
                        .zIndex(0)
                    } else {
                        DetailView(
                            todayCommits: 0,
                            thisWeekCommits: 0,
                            consecutiveCommits: 0
                        )
                        .padding(.vertical)
                        .zIndex(0)
                    }
                }
            }
            .refreshable {
                
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
        
        LoginManager.shared.fetchContributionsData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.contributionsData = data
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    print("Failed to fetch contributions data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 오늘 커밋 수
    func calculateTodayCommits(from contributionsData: ContributionsData) -> Int {
        // 모든 주의 기여일을 하나의 배열로 만듬
        let contributionDays = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.flatMap { $0.contributionDays }
        
        // 마지막 날이 오늘인 경우 오늘의 커밋 수를 반환
        if let todayContribution = contributionDays.last {
            return todayContribution.contributionCount
        }
        
        return 0
    }

    // 이번 주 커밋 수
    func calculateThisWeekCommits(from contributionsData: ContributionsData) -> Int {
        // 최근 주의 기여 데이터를 가져옴
        let currentWeek = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.last
        
        // 이번 주 모든 날의 커밋 수를 합산
        let thisWeekCommits = currentWeek?.contributionDays.reduce(0, { $0 + $1.contributionCount }) ?? 0
        
        return thisWeekCommits
    }

    // 연속된 커밋 날짜
    func calculateConsecutiveCommits(from contributionsData: ContributionsData) -> Int {
        let calendar = Calendar.current
        var consecutiveCommits = 0
        var previousDate: Date?
        
        // contributionDays를 역순으로 탐색
        for week in contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.reversed() {
            for day in week.contributionDays.reversed() {
                // 날짜를 Date 타입으로 변환
                if let currentDate = dateFormatter.date(from: day.date) {
                    // 만약 이전 날짜가 없다면, 즉 첫 번째 날짜이면 처리
                    if previousDate == nil {
                        if day.contributionCount > 0 {
                            consecutiveCommits += 1
                            previousDate = currentDate
                        }
                    } else {
                        // 이전 날짜가 있다면, 그 날짜와 현재 날짜의 차이를 계산
                        let difference = calendar.dateComponents([.day], from: currentDate, to: previousDate!).day
                        if difference == 1 {
                            if day.contributionCount > 0 {
                                consecutiveCommits += 1
                                previousDate = currentDate
                            } else {
                                // 커밋이 없는 날이 나오면 연속이 끊김
                                return consecutiveCommits
                            }
                        } else {
                            // 날짜가 연속되지 않으면 종료
                            return consecutiveCommits
                        }
                    }
                }
            }
        }
        
        return consecutiveCommits
    }

    // 날짜 포맷터
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
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
