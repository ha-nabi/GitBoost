//
//  SettingView.swift
//  GitBoost
//
//  Created by 강치우 on 10/6/24.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                List {
                    // Notification Section
                    Section("Notification") {
                        HStack {
                            Label {
                                Text(AppLocalized.setNotificationsText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    
                            } icon: {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(.white)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $mainViewModel.isNotificationsEnabled)
                                .tint(Color(.systemGreen))
                        }
                    }
                    .padding(.vertical, 2)
                    .listSectionSeparator(.hidden)
                    
                    // Support Section
                    Section("Support") {
                        supportSectionView()
                    }
                    .padding(.vertical, 2)
                    .listSectionSeparator(.hidden)
                    
                    // Information Section
                    Section("Information") {
                        informationSectionView()
                    }
                    .padding(.vertical, 2)
                    .listSectionSeparator(.hidden)
                    
                    // Links Section
                    Section("Links") {
                        linksSectionView()
                    }
                    .listSectionSeparator(.hidden)
                    
                    // Account Section
                    Section("Account") {
                        accountSectionView()
                    }
                    .padding(.vertical, 2)
                    .listSectionSeparator(.hidden)
                }
                .listStyle(.plain)
                .navigationTitle(AppLocalized.settingText)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Text(AppLocalized.dismissText)
                        }
                    }
                }
                .sheet(isPresented: $mainViewModel.showMailView) {
                    MailComposer(
                        result: $mainViewModel.mailResult,
                        recipientEmail: "a2849535@gmail.com",
                        subject: AppLocalized.mailSubject,
                        body: AppLocalized.mailBody
                    )
                }
                .alert(isPresented: $mainViewModel.showMailErrorAlert) {
                    Alert(
                        title: Text("메일 전송 불가"),
                        message: Text("메일 계정이 설정되어 있지 않거나, 메일 전송이 불가능한 상태입니다."),
                        dismissButton: .default(Text("확인"))
                    )
                }
            }
        }
    }
    
    // MARK: - Support Section View
    @ViewBuilder
    private func supportSectionView() -> some View {
        Button {
            let appID = "6708242399"
            let urlString = "https://apps.apple.com/app/id\(appID)?action=write-review"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } label: {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppLocalized.rateText)
                        .font(.callout)
                    Text(AppLocalized.rateSubText)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            } icon: {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
            }
        }
        
        Button {
            mainViewModel.mailButtonTapped()
        } label: {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppLocalized.feedbackText)
                        .font(.callout)
                    Text(AppLocalized.feedbackSubText)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            } icon: {
                Image(systemName: "envelope.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
    }
    
    // MARK: - Information Section View
    @ViewBuilder
    private func informationSectionView() -> some View {
        NavigationLink {
            WebView(url: URL(string: "https://kangciu.notion.site/GitBoost-109518c03e1e80c8b620e34b8cc13676?pvs=4")!)
                .navigationTitle(AppLocalized.policyText)
                .toolbarTitleDisplayMode(.inline)
        } label: {
            Label {
                Text(AppLocalized.policyText)
            } icon: {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(.white)
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
                    .foregroundStyle(.white)
            }
        }
    }
    
    // MARK: - Links Section View
    @ViewBuilder
    private func linksSectionView() -> some View {
        Link(destination: URL(string: "https://github.com/ha-nabi")!) {
            Label {
                HStack {
                    Text("GitHub")
                }
            } icon: {
                Image(systemName: "paperclip")
                    .foregroundStyle(.white)
            }
        }
        
        Link(destination: URL(string: "https://www.instagram.com/dear.kang")!) {
            Label {
                HStack {
                    Text("Instagram")
                }
            } icon: {
                Image(systemName: "paperclip")
                    .foregroundStyle(.white)
            }
        }
    }
    
    // MARK: - Account Section View
    @ViewBuilder
    private func accountSectionView() -> some View {
        Button {
            mainViewModel.showLogoutDialog = true
        } label: {
            Label {
                Text(AppLocalized.Logout)
            } icon: {
                Image(systemName: "door.left.hand.open")
                    .foregroundStyle(.white)
            }
        }
        
        Button {
            mainViewModel.showDeleteAccountDialog = true
        } label: {
            Label {
                Text(AppLocalized.toLeave)
                    .foregroundStyle(Color(.systemRed))
            } icon: {
                Image(systemName: "trash.slash.fill")
                    .foregroundStyle(Color(.systemRed))
            }
        }
    }
}
