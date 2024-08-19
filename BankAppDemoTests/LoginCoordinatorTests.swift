//
//  LoginCoordinatorTests.swift
//  BankAppDemoTests
//
//  Created by 程信傑 on 2024/8/19.
//

@testable import BankAppDemo
import XCTest

class LoginCoordinatorTests: XCTestCase {
	var mockViewModel: MockLoginViewModel!

	override func setUp() {
		super.setUp()
		mockViewModel = MockLoginViewModel()
	}

	override func tearDown() {
		mockViewModel = nil
		super.tearDown()
	}

	/// 利用依賴注入，傳入假的mockViewModel，驗證登入程式邏輯是否有被正確呼叫與處理
	func testLoginViewController() {
		let loginVC = LoginCoordinator(viewModel: mockViewModel)

		// 觸發登入操作
		loginVC.didSelectStatus(1)

		// 驗證 fetchUserData 被調用
		XCTAssertTrue(mockViewModel.fetchUserDataCalled)

		// 模擬成功登入
		mockViewModel.simulateSuccessfulLogin()

		// 驗證 UI 更新
		XCTAssertEqual(mockViewModel.isLoggedIn, true)
		// XCTAssertTrue(loginVC.isShowingMainScreen)

		// 模擬登入失敗
		mockViewModel.simulateFailedLogin()

		// 驗證錯誤處理
		XCTAssertEqual(mockViewModel.isLoggedIn, false)
		// XCTAssertTrue(loginVC.isShowingErrorAlert)
	}
}
