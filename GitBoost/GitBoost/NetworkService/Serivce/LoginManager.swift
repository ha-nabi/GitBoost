//
//  LoginManager.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import AuthenticationServices
import SwiftUI

// MARK: 첫 로그인 때만 사용해서 싱글톤 패턴으로 적용
final class LoginManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    
    static let shared = LoginManager()
    
    private override init() { }
    
    @Published var isLoggedIn: Bool = false
    
    func login() {
        let authURL = "https://github.com/login/oauth/authorize?client_id=\(clientId)&scope=read:user"
        guard let url = URL(string: authURL) else {
            print("Invalid URL")
            return
        }

        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else {
                print("Login failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            let code = queryItems?.first(where: { $0.name == "code" })?.value

            if let code = code {
                self.requestAccessToken(code: code)
            }
        }
        session.presentationContextProvider = self
        session.start()
    }

    func requestAccessToken(code: String) {
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectUri
        ]

        request.httpBody = params.map { "\($0)=\($1)" }.joined(separator: "&").data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let tokenResponse = String(data: data, encoding: .utf8) {
                print("Access Token Response: \(tokenResponse)")
                DispatchQueue.main.async {
                    self.isLoggedIn = true  // 로그인 성공 시 상태 업데이트
                }
            }
        }.resume()
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            
            return UIWindow()
        }
        
        return window
    }
}
