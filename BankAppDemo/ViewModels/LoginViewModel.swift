//
//  LoginViewModel.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import Foundation

// MARK: - LoginViewModelProtocol

protocol LoginViewModelProtocol: AnyObject {
	var user: User? { get }
	var isLoggedIn: Bool { get }
	var userPublisher: Published<User?>.Publisher { get }
	var isLoggedInPublisher: Published<Bool>.Publisher { get }
	func fetchUserData(from dataSource: DataSourceStrategy)
}

// MARK: - LoginViewModel

class LoginViewModel: LoginViewModelProtocol {
	@Published private(set) var user: User? // 儲存使用者資訊
	@Published private(set) var isLoggedIn = false // 儲存是否已登入
	var userPublisher: Published<User?>.Publisher { $user }
	var isLoggedInPublisher: Published<Bool>.Publisher { $isLoggedIn }

	private var cancellables = Set<AnyCancellable>()

	/// 取得使用者資訊
	/// - Parameter dataSources: 資料來源陣列，預設是呼叫遠端
	func fetchUserData(from dataSource: DataSourceStrategy = APIDataSource(endpoint: .user)) {
		// 登入邏輯...
		dataSource.fetchDataPublisher()
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					print("取得使用者資料錯誤: \(error)")
				}
			}, receiveValue: { [weak self] (response: UserResponse) in
				// 假設登入成功並取得使用者資料
				print("成功取得使用者資料：\(response.user)")
				UserSession.shared.saveUserData(response.user)
				self?.user = response.user
				self?.isLoggedIn = true
			})
			.store(in: &cancellables)
	}
}

// MARK: - MockLoginViewModel

class MockLoginViewModel: LoginViewModelProtocol {
	@Published private(set) var user: User?
	@Published private(set) var isLoggedIn = false
	var userPublisher: Published<User?>.Publisher { $user }
	var isLoggedInPublisher: Published<Bool>.Publisher { $isLoggedIn }

	var fetchUserDataCalled = false
	var mockDataSource: DataSourceStrategy?

	func fetchUserData(from dataSource: DataSourceStrategy) {
		fetchUserDataCalled = true
		mockDataSource = dataSource

		// 在這裡，可以模擬成功或失敗的情況
		// 例如：
		// self.user = User(name: "Test User", kokoid: "123")
		// self.isLoggedIn = true
	}

	// 用於測試的輔助方法
	func simulateSuccessfulLogin() {
		user = User(name: "Test User", kokoid: "123")
		isLoggedIn = true
	}

	func simulateFailedLogin() {
		user = nil
		isLoggedIn = false
	}
}
