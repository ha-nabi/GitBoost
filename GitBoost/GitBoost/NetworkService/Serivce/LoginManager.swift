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
    
    @AppStorage("isLoggedIn") private(set) var isLoggedIn: Bool = false
    
    private var accessToken: String? {
        get { loadAccessTokenFromKeychain() }
        set {
            if let token = newValue {
                storeAccessTokenInKeychain(token: token)
            } else {
                removeAccessTokenFromKeychain()
            }
        }
    }
    
    private let baseURL = URL(string: "https://api.github.com")!
    private let graphqlURL = URL(string: "https://api.github.com/graphql")!
    
    // MARK: - 로그인
    func login() {
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&scope=read:user")!
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme) { [weak self] callbackURL, error in
            guard let self = self, error == nil, let callbackURL = callbackURL else {
                print("Login failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            guard let code = URLComponents(string: callbackURL.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else {
                print("No code found in callback URL")
                return
            }

            Task {
                await self.requestAccessToken(code: code)
            }
        }
        session.presentationContextProvider = self
        session.start()
    }

    // MARK: - 액세스 토큰 요청
    private func requestAccessToken(code: String) async {
        let url = URL(string: "https://github.com/login/oauth/access_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectUri
        ]

        request.httpBody = params.percentEncoded()
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let tokenResponse = try JSONDecoder().decode([String: String].self, from: data)
            if let accessToken = tokenResponse["access_token"] {
                self.accessToken = accessToken
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            } else {
                print("Access token not found in response")
            }
        } catch {
            print("Error requesting access token: \(error)")
        }
    }
    
    // MARK: - 로그아웃
    func logout() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoggedIn = false
            self?.accessToken = nil
            print("User logged out.")
        }
    }
    
    // MARK: - 탈퇴하기
    func deleteAccount() async throws {
        try await revokeAccessToken()
        removeAllUserData()
        accessToken = nil
        DispatchQueue.main.async {
            self.isLoggedIn = false
        }
    }
    
    // GitHub에서 토큰 해제
    private func revokeAccessToken() async throws {
        guard let token = accessToken else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token to revoke"])
        }

        var request = URLRequest(url: URL(string: "https://api.github.com/applications/\(clientId)/token")!)
        request.httpMethod = "DELETE"
        let basicAuth = "\(clientId):\(clientSecret)"
        let encodedAuth = Data(basicAuth.utf8).base64EncodedString()
        request.setValue("Basic \(encodedAuth)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["access_token": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 204 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to revoke token"])
        }
    }
    
    // MARK: - API Requests
    func fetchUserInfo() async throws -> UserInfo {
        return try await performAPIRequest(endpoint: "user")
    }

    func fetchContributionsData() async throws -> ContributionsData {
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
        return try await performGraphQLRequest(query: query)
    }

    func fetchAdditionalGitHubData() async throws -> AdditionalGitHubData {
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
        return try await performGraphQLRequest(query: query)
    }

    private func performAPIRequest<T: Decodable>(endpoint: String) async throws -> T {
        guard let token = accessToken else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found"])
        }

        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func performGraphQLRequest<T: Decodable>(query: String) async throws -> T {
        guard let token = accessToken else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found"])
        }

        var request = URLRequest(url: graphqlURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Keychain 관련 메서드
    private func storeAccessTokenInKeychain(token: String) {
        let keychain = Keychain(service: "com.yourapp.gitboost")
        keychain["github_access_token"] = token
    }

    private func loadAccessTokenFromKeychain() -> String? {
        let keychain = Keychain(service: "com.yourapp.gitboost")
        return keychain["github_access_token"]
    }

    private func removeAccessTokenFromKeychain() {
        let keychain = Keychain(service: "com.yourapp.gitboost")
        try? keychain.remove("github_access_token")
    }

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

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}
