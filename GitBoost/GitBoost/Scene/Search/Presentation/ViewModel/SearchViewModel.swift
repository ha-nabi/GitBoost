//
//  SearchViewModel.swift
//  GitBoost
//
//  Created by 강치우 on 10/1/24.
//

import Combine
import Foundation

final class SearchViewModel: ObservableObject {
    @Published var userProfiles: [GitHubUserProfile] = []
    @Published var searchQuery: String = ""
    @Published var isFetching = false // 데이터 요청 중인지 확인

    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let itemsPerPage = 10 // 한 번에 가져올 사용자 수
    
    init() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    self.userProfiles = []
                    self.currentPage = 1
                } else {
                    self.userProfiles = []
                    self.currentPage = 1
                    self.searchUsers(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    func searchUsers(query: String) {
        guard !isFetching else { return } // 데이터 요청 중이면 중복 요청 방지
        isFetching = true
        
        let urlString = "https://api.github.com/search/users?q=\(query)&page=\(currentPage)&per_page=\(itemsPerPage)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResult.self, decoder: JSONDecoder())
            .replaceError(with: SearchResult(items: [])) // 오류 발생 시 빈 결과 반환
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.fetchUserProfiles(users: result.items) // 검색 결과를 받은 후 각 사용자의 프로필을 요청
                self?.currentPage += 1
                self?.isFetching = false
            }
            .store(in: &cancellables)
    }

    // 개별 사용자의 프로필을 가져와서 name을 받아오는 함수
    func fetchUserProfiles(users: [GitHubUserProfile]) {
        let token = LoginManager.shared.loadAccessTokenFromKeychain() ?? ""
        let headers = ["Authorization": "token \(token)"]
        
        let publishers = users.map { user in
            var request = URLRequest(url: URL(string: "https://api.github.com/users/\(user.login)")!)
            request.allHTTPHeaderFields = headers
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { result -> Data in
                    if let response = result.response as? HTTPURLResponse, response.statusCode != 200 {
                        throw URLError(.badServerResponse)
                    }
                    return result.data
                }
                .decode(type: GitHubUserProfile.self, decoder: JSONDecoder())
                .catch { error -> Just<GitHubUserProfile> in
                    print("Error fetching profile for \(user.login): \(error.localizedDescription)")
                    return Just(GitHubUserProfile(id: user.id, login: user.login, name: nil, avatarUrl: user.avatarUrl))
                }
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profiles in
                self?.userProfiles.append(contentsOf: profiles)
            }
            .store(in: &cancellables)
    }
    
    // 무한스크롤
    func fetchMoreUsers() {
        searchUsers(query: searchQuery)
    }
}
