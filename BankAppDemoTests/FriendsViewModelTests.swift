//
//  FriendsViewModelTests.swift
//  BankAppDemoTests
//
//  Created by 程信傑 on 2024/8/18.
//

@testable import BankAppDemo
import XCTest

class FriendsViewModelTests: XCTestCase {
	var viewModel: FriendsViewModel!
    
	override func setUp() {
		super.setUp()
		viewModel = FriendsViewModel()
	}
    
	override func tearDown() {
		viewModel = nil
		super.tearDown()
	}
    
	/// 測試從單一資料來源取得朋友列表
	func testFetchFriendsWithSingleDataSource() {
		let expectation = XCTestExpectation(description: "取得單一資料來源的朋友列表")
        
		let dataSource = LocalDataSource(localFileName: "friend3")
		viewModel.fetchFriends(from: [dataSource])
        
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			XCTAssertEqual(self.viewModel.combinedFriends.count, 5)
			XCTAssertEqual(self.viewModel.filteredFriends.count, 5)
            
			// 檢查特定朋友是否存在
			let expectedFriend = Friend(name: "黃靖僑", status: 0, isTop: false, fid: "001", updateDate: "20190801")
			XCTAssertTrue(self.viewModel.combinedFriends.contains { $0.fid == expectedFriend.fid }, "朋友列表應包含特定朋友")
            
			expectation.fulfill()
		}
        
		wait(for: [expectation], timeout: 2)
	}
    
	/// 測試從多個資料來源取得朋友列表
	func testFetchFriendsWithMultipleDataSources() {
		let expectation = XCTestExpectation(description: "取得多個資料來源的朋友列表")
        
		let dataSource1 = LocalDataSource(localFileName: "friend1")
		let dataSource2 = LocalDataSource(localFileName: "friend2")
		viewModel.fetchFriends(from: [dataSource1, dataSource2])
        
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			XCTAssertEqual(self.viewModel.combinedFriends.count, 6)
			XCTAssertEqual(self.viewModel.filteredFriends.count, 6)
            
			// 檢查特定朋友是否存在（來自第二個資料源）
			let expectedFriend = Friend(name: "林宜真", status: 1, isTop: false, fid: "012", updateDate: "2019/08/01")
			XCTAssertTrue(self.viewModel.combinedFriends.contains { $0.fid == expectedFriend.fid }, "朋友列表應包含來自第二個資料源的特定朋友")
            
			expectation.fulfill()
		}
        
		wait(for: [expectation], timeout: 2)
	}
    
	/// 測試從空資料來源取得朋友列表
	func testFetchFriendsWithEmptyDataSource() {
		let expectation = XCTestExpectation(description: "取得空資料來源的朋友列表")
        
		let dataSource = LocalDataSource(localFileName: "friend4")
		viewModel.fetchFriends(from: [dataSource])
        
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			XCTAssertEqual(self.viewModel.combinedFriends.count, 0)
			XCTAssertEqual(self.viewModel.filteredFriends.count, 0)
			expectation.fulfill()
		}
        
		wait(for: [expectation], timeout: 2)
	}
    
	/// 測試朋友過濾功能
	func testFilterFriends() {
		let expectation = XCTestExpectation(description: "測試朋友過濾功能")
        
		let dataSource = LocalDataSource(localFileName: "friend1")
		viewModel.fetchFriends(from: [dataSource])
        
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.viewModel.filterFriends(with: "黃")
			XCTAssertEqual(self.viewModel.filteredFriends.count, 1)
            
			// 檢查過濾後的朋友是否正確
			let expectedFriend = Friend(name: "黃靖僑", status: 0, isTop: false, fid: "001", updateDate: "20190801")
			XCTAssertTrue(self.viewModel.filteredFriends.contains { $0.fid == expectedFriend.fid }, "過濾後的朋友列表應包含特定朋友")
            
			self.viewModel.filterFriends(with: "")
			XCTAssertEqual(self.viewModel.filteredFriends.count, 5)
            
			expectation.fulfill()
		}
        
		wait(for: [expectation], timeout: 2)
	}
}
