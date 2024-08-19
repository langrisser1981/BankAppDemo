//
//  FriendsViewModel.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import Foundation

class FriendsViewModel: ObservableObject {
	@Published private(set) var user: User? // 儲存使用者資訊
	@Published private(set) var combinedFriends: [Friend] = [] // 儲存所有好友
	@Published private(set) var filteredFriends: [Friend] = [] // 儲存過濾後的好友

	private var cancellables = Set<AnyCancellable>()

	init() {
		bindViewModel()
	}

	private func bindViewModel() {
		UserSession.shared.$userData
			.compactMap { $0 }
			.assign(to: \.user, on: self)
			.store(in: &cancellables)
	}

	/// 取得朋友列表
	/// - Parameter dataSources: 資料來源陣列
	func fetchFriends(from dataSources: [DataSourceStrategy]) {
		APIService.shared.fetchFriends(for: dataSources)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					print("取得朋友列表錯誤: \(error)")
				}
			}, receiveValue: { [weak self] friends in
				print("成功取得朋友列表：\(friends)")
				self?.combinedFriends = friends
				self?.filteredFriends = friends
			})
			.store(in: &cancellables)
	}

	/// 根據搜尋文字過濾好友
	/// - Parameter searchText: 搜尋文字
	func filterFriends(with searchText: String) {
		if searchText.isEmpty {
			filteredFriends = combinedFriends
		} else {
			filteredFriends = combinedFriends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
		}
	}
}
