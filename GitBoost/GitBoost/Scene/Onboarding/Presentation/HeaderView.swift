//
//  HeaderView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

struct HeaderView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    @Binding var activePage: Page
    @Binding var showAlert: Bool
    
    @State private var verificationCode: String = ""
    @State private var isInputValid: Bool = false
    @State private var isVerified: Bool = false
    
    var body: some View {
        HStack {
            Button {
                activePage = activePage.previousPage
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .contentShape(.rect)
            }
            .opacity(activePage != .page1 ? 1 : 0)
            
            Spacer(minLength: 0)
            
            if activePage != .page3 {
                Button("Skip") {
                    activePage = .page3
                }
                .fontWeight(.semibold)
                .opacity(activePage != .page3 ? 1 : 0)
            } else {
                Menu {
                    Button {
                        showAlert.toggle()
                    } label: {
                        Label {
                            Text("For AppStore Review")
                        } icon: {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                        }
                    }
                } label: {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .contentShape(.rect)
                }
                .alert("Enter Review Code", isPresented: $showAlert) {
                    TextField("Enter a number", text: $verificationCode)
                        .keyboardType(.numberPad)
                    
                    Button("Submit") {
                        verifyCode()
                    }
                    Button("Cancel", role: .cancel) {
                        verificationCode = ""
                    }
                } message: {
                    Text("Please enter the code you received from the App Store review.")
                }
            }
        }
        .foregroundStyle(.white)
        .animation(.snappy(duration: 0.35, extraBounce: 0), value: activePage)
        .padding(15)
        .navigationDestination(isPresented: $isVerified) {
            ContentView()
        }
    }
    
    private func verifyCode() {
        if verificationCode == validCode {
            isVerified = true
            verificationCode = ""
            print("통과")
        } else {
            isVerified = false
            verificationCode = ""
            print("실패")
        }
    }
}
