//
//  AppCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import UIKit

// MARK: - AppCoordinator

class AppCoordinator: Coordinator {
	private var loginCoordinator: LoginCoordinator?
	private var homeCoordinator: HomeCoordinator?

	override func start() {
		// 應用程式啟動時顯示登入畫面
		showMainScreen()
	}

	private func showMainScreen() {
		if UserSession.shared.userData != nil {
			// 使用者已登入，顯示首頁
			showHomeScreen()
		} else {
			// 使用者未登入，顯示登入畫面
			showLoginScreen()
		}
	}

	// 建立並顯示登入畫面
	private func showLoginScreen() {
		let loginCoordinator = LoginCoordinator()
		loginCoordinator.delegate = self
		add(childController: loginCoordinator)
		self.loginCoordinator = loginCoordinator
	}

	// 建立並顯示首頁
	private func showHomeScreen() {
		let homeCoordinator = HomeCoordinator()
		homeCoordinator.delegate = self
		add(childController: homeCoordinator)
		self.homeCoordinator = homeCoordinator
	}
}

// MARK: LoginCoordinatorDelegate

extension AppCoordinator: LoginCoordinatorDelegate {
	// 處理登入成功的情況
	func didLogin(_ coordinator: LoginCoordinator) {
		// 移除 loginCoordinator
		remove(childController: coordinator)
		loginCoordinator = nil

		// 顯示首頁
		showHomeScreen()
	}
}

// MARK: HomeCoordinatorDelegate

extension AppCoordinator: HomeCoordinatorDelegate {
	// 處理登出請求
	func didRequestLogout(_ coordinator: HomeCoordinator) {
		// 移除 homeCoordinator
		remove(childController: coordinator)
		homeCoordinator = nil

		// 顯示登入畫面
		showLoginScreen()
	}
}

// MARK: - UserDefaultsKeys

enum UserDefaultsKeys {
	// 此值代表使用者在登入時選擇的狀態
	// 該狀態將影響後續呼叫的資料來源
	static let userStatus = "userStatus"
}
