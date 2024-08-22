//
//   FriendsViewControllerTests.swift
//  BankAppDemoTests
//
//  Created by 程信傑 on 2024/8/22.
//

@testable import BankAppDemo
import Combine
import XCTest

// MARK: - FriendsViewControllerTests

class FriendsViewControllerTests: XCTestCase {
	var sut: FriendsViewController!
	var viewModel: FriendsViewModel!
	var cancellables: Set<AnyCancellable>!

	override func setUp() {
		super.setUp()
		cancellables = []
		viewModel = FriendsViewModel()
		sut = FriendsViewController(viewModel: viewModel)
		sut.viewDidLoad()
	}

	override func tearDown() {
		sut = nil
		viewModel = nil
		cancellables = nil
		super.tearDown()
	}

	// 測試案例：當沒有朋友資料時，畫面應該顯示空狀態
	func testUpdateDisplayWithNoFriends() {
		// 準備
		let expectation = XCTestExpectation(description: "取得空資料來源的朋友列表")
		let dataSource = LocalDataSource(localFileName: "friend4")

		// 執行
		viewModel.fetchFriends(from: [dataSource])

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.sut.updateDisplay()

			// 驗證
			XCTAssertFalse(self.sut.isViewHidden(.emptyState))
			XCTAssertTrue(self.sut.isViewHidden(.invitationsTable))
			XCTAssertTrue(self.sut.isViewHidden(.searchBar))
			XCTAssertTrue(self.sut.isViewHidden(.friendsTable))

			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 2)
	}

	// 測試案例：當有朋友資料但沒有邀請時，畫面應該顯示朋友列表和搜尋欄
	func testUpdateDisplayWithFriendsButNoInvitations() {
		// 準備
		let expectation = XCTestExpectation(description: "取得朋友列表但無邀請")
		let dataSource1 = LocalDataSource(localFileName: "friend1")
		let dataSource2 = LocalDataSource(localFileName: "friend2")

		// 執行
		viewModel.fetchFriends(from: [dataSource1, dataSource2])

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.sut.updateDisplay()

			// 驗證
			XCTAssertTrue(self.sut.isViewHidden(.emptyState))
			XCTAssertTrue(self.sut.isViewHidden(.invitationsTable))
			XCTAssertFalse(self.sut.isViewHidden(.searchBar))
			XCTAssertFalse(self.sut.isViewHidden(.friendsTable))

			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 2)
	}

	// 測試案例：當同時有朋友資料和邀請時，畫面應該顯示朋友列表、邀請列表和搜尋欄
	func testUpdateDisplayWithFriendsAndInvitations() {
		// 準備
		let expectation = XCTestExpectation(description: "取得朋友列表和邀請")
		let dataSource = LocalDataSource(localFileName: "friend3")

		// 執行
		viewModel.fetchFriends(from: [dataSource])

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.sut.updateDisplay()

			// 驗證
			XCTAssertTrue(self.sut.isViewHidden(.emptyState))
			XCTAssertFalse(self.sut.isViewHidden(.invitationsTable))
			XCTAssertFalse(self.sut.isViewHidden(.searchBar))
			XCTAssertFalse(self.sut.isViewHidden(.friendsTable))

			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 2)
	}

	// 測試案例：驗證好友泡泡的數量是否正確更新
	func testUpdateFriendsBubble() {
		// 準備
		let expectation = XCTestExpectation(description: "更新好友泡泡")
		let dataSource = LocalDataSource(localFileName: "friend3")

		// 執行
		viewModel.fetchFriends(from: [dataSource])

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			// 驗證
			// 註: 根據 friend3.json 的內容，應該有兩個 status == 2 的好友
			XCTAssertEqual(self.sut.getFriendsBubbleCount(), 2)
			XCTAssertEqual(self.sut.getFriendsBubbleNumber(), 2)

			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 2)
	}
}

// 註: 以下是一些重要的註解說明

// 1. 測試案例結構
// - 每個測試方法都遵循「準備-執行-驗證」的結構
// - 使用 XCTestExpectation 來處理非同步操作

// 2. 資料來源
// - 使用 LocalDataSource 類別來模擬不同的資料情境
// - 不同的 JSON 檔案（如 friend1, friend2, friend3, friend4）代表不同的測試資料集

// 3. 視圖更新測試
// - testUpdateDisplayWithNoFriends: 測試沒有朋友時的畫面狀態
// - testUpdateDisplayWithFriendsButNoInvitations: 測試有朋友但沒有邀請時的畫面狀態
// - testUpdateDisplayWithFriendsAndInvitations: 測試同時有朋友和邀請時的畫面狀態

// 4. 好友泡泡測試
// - testUpdateFriendsBubble: 測試好友泡泡的數量更新是否正確

// 5. 非同步處理
// - 使用 DispatchQueue.main.asyncAfter 來模擬資料載入的延遲
// - 使用 wait(for:timeout:) 方法來等待非同步操作完成

// 6. 視圖元件可見性測試
// - 使用 isViewHidden 方法來檢查不同元件的可見性狀態
