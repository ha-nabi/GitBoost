//
//  Home.swift
//  GitBoost
//
//  Created by 강치우 on 9/19/24.
//

import SwiftUI

struct Home: View {
    var safeArea: EdgeInsets
    var size: CGSize
    
    @State private var scrollViewOffset: CGFloat = 0
    
    @State private var showLogoutDialog = false
    @State private var showDeleteAccountDialog = false
    
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
        }
        .navigationBarTitle(scrollViewOffset > 100 ? "" : "ha-nabi".uppercased(), displayMode: .inline)
        .toolbar {
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
        let height = size.height * 0.45
        
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))
            
            Image("im1")
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
                            Text("치우")
                                .font(.system(size: 45))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("ha-nabi".uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding(.top, 15)
                                .onScrollViewOffsetChange { offset in
                                    scrollViewOffset = offset
                                }
                        }
                        .opacity(1 + (progress > 0 ? -progress : progress))
                        .padding(.bottom, 55)
                        .offset(y: minY < 0 ? minY : 0)
                    }
                }
                .offset(y: -minY)
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
