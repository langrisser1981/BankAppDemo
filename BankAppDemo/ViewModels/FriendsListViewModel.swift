//
//  FriendsListViewModel.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import Foundation

class FriendsListViewModel {
	// 用於儲存和管理訂閱
	private var cancellables = Set<AnyCancellable>()
    
	// 儲存數據源策略的陣列
	private let dataSources: [DataSourceStrategy]
    
	// 發布合併後的好友列表，只允許內部設定
	@Published private(set) var combinedFriends: [Friend] = []
    
	// 發布過濾後的好友列表，只允許內部設定
	@Published private(set) var filteredFriends: [Friend] = []
    
	// 初始化方法，接受一個或多個數據源策略
	init(dataSources: [DataSourceStrategy]) {
		self.dataSources = dataSources
	}
    
	// 獲取並合併好友列表的方法
	func fetchAndCombineFriendsList() {
		// 將每個數據源轉換為發布者
		let publishers = dataSources.map { $0.fetchDataPublisher() as AnyPublisher<FriendResponse, Error> }
        
		// 使用 Publishers.MergeMany 合併所有發布者
		Publishers.MergeMany(publishers)
			.collect() // 收集所有結果
			.map { responses in
				// 將所有回應([FriendResponse])中的好友列表(friends)合併為單一個陣列
				responses.flatMap { $0.friends }
			}
			.map { self.mergeFriends($0) } // 合併重複的好友
			.sink(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					print("錯誤: \(error)")
				}
			}, receiveValue: { [weak self] friends in
				// 更新合併後的好友列表
				self?.combinedFriends = friends
				self?.filteredFriends = friends
			})
			.store(in: &cancellables) // 存儲訂閱以便後續取消
	}
    
	// 過濾好友列表的方法
	func filterFriends(with searchText: String) {
		if searchText.isEmpty {
			filteredFriends = combinedFriends
		} else {
			filteredFriends = combinedFriends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
		}
	}
    
	// 合併重複好友的私有方法
	private func mergeFriends(_ friends: [Friend]) -> [Friend] {
		var uniqueFriends: [String: Friend] = [:]
        
		for friend in friends {
			if let existingFriend = uniqueFriends[friend.fid] {
				// 如果已存在相同 ID 的好友，比較更新日期
				if friend.updateDate > existingFriend.updateDate {
					uniqueFriends[friend.fid] = friend
				}
			} else {
				// 如果是新的好友，直接添加
				uniqueFriends[friend.fid] = friend
			}
		}
        
		// 返回合併後的好友列表
		return Array(uniqueFriends.values)
	}
}
