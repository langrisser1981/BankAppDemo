//
//  FriendsCoordinatorTests.swift
//  BankAppDemoTests
//
//  Created by 程信傑 on 2024/8/18.
//

@testable import BankAppDemo
import XCTest

class FriendsCoordinatorTests: XCTestCase {
	func testFriendsCoordinatorWithStatus1() {
		let coordinator = FriendsCoordinator()
		let expectation = XCTestExpectation(description: "獲取朋友列表")
        
		// 設置用戶狀態為 1
		UserDefaults.standard.set(1, forKey: UserDefaultsKeys.userStatus)
        
		coordinator.start()
        
		// 等待一小段時間後檢查結果
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			// 驗證狀態 1 沒有朋友
			XCTAssertEqual(coordinator.viewModel.combinedFriends.count, 0, "狀態 1 應該沒有朋友")
			// 標記測試期望已完成
			expectation.fulfill()
		}
        
		// 等待期望完成，超時時間為 2 秒
		wait(for: [expectation], timeout: 2)
	}
    
	func testFriendsCoordinatorWithStatus2() {
		let coordinator = FriendsCoordinator()
		let expectation = XCTestExpectation(description: "獲取朋友列表")
        
		UserDefaults.standard.set(2, forKey: UserDefaultsKeys.userStatus)
        
		coordinator.start()
        
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			// 驗證狀態 2 有 6 個朋友
			XCTAssertEqual(coordinator.viewModel.combinedFriends.count, 6, "狀態 2 應該有 6 個朋友")
			expectation.fulfill()
		}
        
		wait(for: [expectation], timeout: 2)
	}
    
	func testFriendsCoordinatorWithStatus3() {
		let coordinator = FriendsCoordinator()
		let expectation = XCTestExpectation(description: "獲取朋友列表")
        
		// 設置用戶狀態為 3
		UserDefaults.standard.set(3, forKey: UserDefaultsKeys.userStatus)
        
		coordinator.start()
        
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			// 驗證狀態 3 有 5 個朋友
			XCTAssertEqual(coordinator.viewModel.combinedFriends.count, 5, "狀態 3 應該有 5 個朋友")
			expectation.fulfill()
		}
        
		wait(for: [expectation], timeout: 2)
	}
}
