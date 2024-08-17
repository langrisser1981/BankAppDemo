//
//  AppCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import UIKit

// MARK: - AppCoordinator

class AppCoordinator: Coordinator {
	// 添加以下屬性
	private var loginCoordinator: LoginCoordinator?
	private var homeCoordinator: HomeCoordinator?

	override func start() {
		// 設置背景顏色為白色
		view.backgroundColor = .white
		showLoginCoordinator()
	}

	private func showLoginCoordinator() {
		loginCoordinator = LoginCoordinator()
		loginCoordinator?.delegate = self
		guard let loginCoordinator = loginCoordinator else {
			// 處理 loginCoordinator 為 nil 的情況
			print("錯誤：無法創建 LoginCoordinator")
			return
		}
		add(childController: loginCoordinator)
	}

	private func showHomeCoordinator(with status: Int) {
		homeCoordinator = HomeCoordinator()
		guard let homeCoordinator = homeCoordinator else {
			// 處理 homeCoordinator 為 nil 的情況
			print("錯誤：無法創建 HomeCoordinator")
			return
		}
		add(childController: homeCoordinator)
	}
}

// MARK: LoginCoordinatorDelegate

extension AppCoordinator: LoginCoordinatorDelegate {
	func didSelectStatus(_ status: Int) {
		guard let loginCoordinator = loginCoordinator else {
			print("警告：loginCoordinator 為 nil")
			return
		}
		remove(childController: loginCoordinator)
		showHomeCoordinator(with: status)
	}
}

// MARK: - UserDefaultsKeys

enum UserDefaultsKeys {
	// 此值代表使用者在登入時選擇的狀態
	// 該狀態將影響後續呼叫的資料來源
	static let userStatus = "userStatus"
}
