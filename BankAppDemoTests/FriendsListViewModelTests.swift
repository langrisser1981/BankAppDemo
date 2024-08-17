//
//  FriendsListViewModelTests.swift
//  BankAppDemoTests
//
//  Created by 程信傑 on 2024/8/18.
//

@testable import BankAppDemo
import Combine
import XCTest

class FriendsListViewModelTests: XCTestCase {
	var viewModel: FriendsListViewModel!
	var cancellables: Set<AnyCancellable>!
    
	override func setUpWithError() throws {
		super.setUp()
		cancellables = Set<AnyCancellable>()
	}
    
	override func tearDownWithError() throws {
		viewModel = nil
		cancellables = nil
		super.tearDown()
	}
    
	func testFetchAndCombineFriendsListWithLocalJSON() {
		// 創建使用本地 JSON 文件的數據源
		let localDataSource1 = LocalDataSource(localFileName: "friend1")
		let localDataSource2 = LocalDataSource(localFileName: "friend2")
        
		// 初始化 ViewModel
		viewModel = FriendsListViewModel(dataSources: [localDataSource1, localDataSource2])
        
		// 創建期望
		let expectation = XCTestExpectation(description: "Fetch friends list")
        
		// 訂閱 combinedFriends 的變化
		viewModel.$combinedFriends
			.dropFirst() // 忽略初始空陣列
			.sink { friends in
				// 驗證結果
				XCTAssertEqual(friends.count, 6, "合併後應該有 6 個好友")
                
				// 驗證特定好友的存在
				XCTAssertTrue(friends.contains { $0.name == "黃靖僑" })
				XCTAssertTrue(friends.contains { $0.name == "翁勳儀" })
				XCTAssertTrue(friends.contains { $0.name == "洪佳妤" })
				XCTAssertTrue(friends.contains { $0.name == "梁立璇" })
				XCTAssertTrue(friends.contains { $0.name == "林宜真" })
                
				// 驗證合併邏輯
				let updatedFriend = friends.first { $0.fid == "001" }
				XCTAssertEqual(updatedFriend?.status, 1, "fid 001 的好友狀態應該更新為 1")
                
				expectation.fulfill()
			}
			.store(in: &cancellables)
        
		// 觸發獲取好友列表
		viewModel.fetchAndCombineFriendsList()
        
		// 等待期望完成
		wait(for: [expectation], timeout: 5.0)
	}
}
