//
//  LoginManager.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import AuthenticationServices
import KeychainAccess
import SwiftUI

final class LoginManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    
    static let shared = LoginManager()
    
    private override init() { }
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    private var accessToken: String?
    
    private let baseURL = "https://api.github.com"
    private let graphqlURL = "https://api.github.com/graphql"
    
    // MARK: - 로그인
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

    // MARK: - 액세스 토큰 요청
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
            if let error = error {
                print("Error requesting access token: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                // JSON으로 액세스 토큰을 디코드
                let tokenResponse = try JSONDecoder().decode([String: String].self, from: data)
                if let accessToken = tokenResponse["access_token"] {
                    print("Access Token: \(accessToken)")
                    
                    // 액세스 토큰 저장
                    self.accessToken = accessToken
                    self.storeAccessTokenInKeychain(token: accessToken)
                    
                    DispatchQueue.main.async {
                        self.isLoggedIn = true  // 로그인 성공 시 상태 업데이트
                    }
                } else {
                    print("Access token not found in response")
                }
            } catch {
                print("Error decoding access token: \(error)")
            }
        }.resume()
    }
    
    // MARK: - 로그아웃
    func logout() {
        // 상태를 초기화하고 Keychain에서 토큰 삭제
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.accessToken = nil
            self.removeAccessTokenFromKeychain()
            print("User logged out.")
        }
    }
    
    // MARK: - 탈퇴하기
    func deleteAccount() {
        // GitHub에서 액세스 토큰 해제
        revokeAccessToken()

        // 앱 데이터 삭제
        removeAllUserData()

        // Keychain에서 토큰 삭제
        removeAccessTokenFromKeychain()

        // 로그인 상태를 초기화하여 로그인 화면으로 돌아가도록 설정
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.accessToken = nil
        }

        print("Account deleted and all user data removed")
    }
    
    // GitHub에서 토큰 해제
    private func revokeAccessToken() {
        guard let token = loadAccessTokenFromKeychain() else {
            print("No token to revoke")
            return
        }

        let url = URL(string: "https://api.github.com/applications/\(clientId)/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let basicAuth = "\(clientId):\(clientSecret)"
        let encodedAuth = Data(basicAuth.utf8).base64EncodedString()
        request.setValue("Basic \(encodedAuth)", forHTTPHeaderField: "Authorization")

        let body = ["access_token": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error revoking token: \(error)")
                return
            }
            print("Successfully revoked token.")
        }.resume()
    }
    
    // GitHub에서 사용자 정보 가져오기
    func fetchUserInfo(completion: @escaping (Result<UserInfo, Error>) -> Void) {
        guard let token = loadAccessTokenFromKeychain() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found"])))
            return
        }

        let url = URL(string: "\(baseURL)/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
                completion(.success(userInfo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // GraphQL로 contributions 정보 가져오기
    func fetchContributionsData(completion: @escaping (Result<ContributionsData, Error>) -> Void) {
        guard let token = loadAccessTokenFromKeychain() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found"])))
            return
        }

        let url = URL(string: graphqlURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // GraphQL Query
        let query = """
        {
            viewer {
                contributionsCollection {
                    contributionCalendar {
                        weeks {
                            contributionDays {
                                date
                                contributionCount
                            }
                        }
                    }
                }
            }
        }
        """

        let body = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let contributionsData = try JSONDecoder().decode(ContributionsData.self, from: data)
                completion(.success(contributionsData))
            } catch {
                print("Error decoding contributions data: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Keychain 저장
    private func storeAccessTokenInKeychain(token: String) {
        let keychain = Keychain(service: "com.yourapp.gitboost")
        keychain["github_access_token"] = token
    }

    // MARK: - Keychain에서 불러오기
    func loadAccessTokenFromKeychain() -> String? {
        let keychain = Keychain(service: "com.yourapp.gitboost")
        return keychain["github_access_token"]
    }

    // MARK: - Keychain에서 삭제
    private func removeAccessTokenFromKeychain() {
        let keychain = Keychain(service: "com.yourapp.gitboost")
        try? keychain.remove("github_access_token")
    }

    // 앱의 모든 데이터 삭제 ex. UserDefaults
    private func removeAllUserData() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }

    // MARK: - UI Presentation
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

extension LoginManager {
    func fetchAdditionalGitHubData(completion: @escaping (Result<AdditionalGitHubData, Error>) -> Void) {
        guard let token = loadAccessTokenFromKeychain() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found"])))
            return
        }

        let url = URL(string: graphqlURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let query = """
        {
            viewer {
                contributionsCollection {
                    totalCommitContributions
                }
                repositories(first: 100) {
                    nodes {
                        stargazerCount
                    }
                }
                pullRequests(last: 100) {
                    totalCount
                }
                repositoriesContributedTo(last: 1) {
                    totalCount
                }
            }
        }
        """

        let body = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let additionalGitHubData = try JSONDecoder().decode(AdditionalGitHubData.self, from: data)
                completion(.success(additionalGitHubData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}