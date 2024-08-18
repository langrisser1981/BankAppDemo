//
//  LoginViewModel.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import Foundation

class LoginViewModel {
	@Published private(set) var user: User? // 儲存使用者資訊
	@Published private(set) var isLoggedIn = false // 儲存是否已登入

	private var cancellables = Set<AnyCancellable>()

	/// 取得使用者資訊
	/// - Parameter dataSources: 資料來源陣列，預設是呼叫遠端
	func fetchUserData(from dataSource: DataSourceStrategy = APIDataSource(endpoint: .user)) {
		dataSource.fetchDataPublisher()
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					print("取得使用者資料錯誤: \(error)")
				}
			}, receiveValue: { [weak self] (response: UserResponse) in
				print("成功取得使用者資料：\(response.user)")
				self?.user = response.user
				self?.isLoggedIn = true
			})
			.store(in: &cancellables)
	}
}
