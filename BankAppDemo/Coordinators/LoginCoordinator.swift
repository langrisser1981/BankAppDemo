//
//  LoginCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import Foundation
import UIKit

// MARK: - LoginCoordinatorDelegate

protocol LoginCoordinatorDelegate: AnyObject {
	func didLogin(_ coordinator: LoginCoordinator)
}

// MARK: - LoginCoordinator

class LoginCoordinator: Coordinator {
	weak var delegate: LoginCoordinatorDelegate?
	private let viewModel: LoginViewModelProtocol
	private var loginViewController: LoginViewController!

	init(viewModel: LoginViewModelProtocol = LoginViewModel()) {
		self.viewModel = viewModel
		super.init()
	}

	override func start() {
		// 初始化 ViewController
		loginViewController = LoginViewController(viewModel: viewModel)
		loginViewController.delegate = self
		add(childController: loginViewController)
	}

	override func bindViewModel() {
		// 監聽登入狀態變化
		viewModel.isLoggedInPublisher
			.filter { $0 }
			.sink { [weak self] _ in
				self?.handleLoginCompleted()
			}
			.store(in: &cancellables)
	}

	// 處理登入完成後的操作
	private func handleLoginCompleted() {
		delegate?.didLogin(self)
	}
}

// MARK: LoginViewControllerDelegate

extension LoginCoordinator: LoginViewControllerDelegate {
	func didSelectStatus(_ status: Int) {
		// 儲存使用者狀態到 UserDefaults
		UserDefaults.standard.set(status, forKey: UserDefaultsKeys.userStatus)

		// 取得使用者資料
		viewModel.fetchUserData(from: APIDataSource(endpoint: .user))
	}
}
