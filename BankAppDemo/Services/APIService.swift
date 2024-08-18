//
//  APIService.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/18.
//

import Combine
import Foundation

// MARK: - APIService

class APIService {
	static let shared = APIService()
    
	private init() {}
    
	/// API 端點列舉，定義了所有可用的 API URL
	enum APIEndpoint: String {
		case user = "https://dimanyen.github.io/man.json"
		case friend1 = "https://dimanyen.github.io/friend1.json"
		case friend2 = "https://dimanyen.github.io/friend2.json"
		case friendWithInvites = "https://dimanyen.github.io/friend3.json"
		case noFriends = "https://dimanyen.github.io/friend4.json"
	}
    
	// 取得使用者資料
	func fetchUserData(dataSource: DataSourceStrategy) -> AnyPublisher<User, Error> {
		dataSource.fetchDataPublisher()
			.map { (response: UserResponse) in response.user }
			.eraseToAnyPublisher()
	}
    
	// 取得朋友清單
	func fetchFriends(for dataSources: [DataSourceStrategy]) -> AnyPublisher<[Friend], Error> {
		Publishers.MergeMany(dataSources.map { $0.fetchDataPublisher() })
			.collect()
			.map { responses in
				responses.flatMap { (response: FriendResponse) in response.friends }
			}
			.map { self.mergeFriends($0) }
			.eraseToAnyPublisher()
	}
    
	// 合併朋友清單，移除重複項並保留最新的更新日期
	private func mergeFriends(_ friends: [Friend]) -> [Friend] {
		var uniqueFriends: [String: Friend] = [:]
		for friend in friends {
			if let existingFriend = uniqueFriends[friend.fid] {
				if friend.updateDate > existingFriend.updateDate {
					uniqueFriends[friend.fid] = friend
				}
			} else {
				uniqueFriends[friend.fid] = friend
			}
		}
		return Array(uniqueFriends.values)
	}
}
