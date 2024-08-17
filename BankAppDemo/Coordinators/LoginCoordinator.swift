//
//  LoginCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Foundation
import UIKit

// MARK: - LoginCoordinatorDelegate

protocol LoginCoordinatorDelegate: AnyObject {
	func didSelectStatus(_ status: Int)
}

// MARK: - LoginCoordinator

class LoginCoordinator: Coordinator {
	weak var delegate: LoginCoordinatorDelegate?

	override func start() {
		let loginViewController = LoginViewController()
		loginViewController.delegate = self
		add(childController: loginViewController)
	}
}

// MARK: LoginViewControllerDelegate

extension LoginCoordinator: LoginViewControllerDelegate {
	func didSelectStatus(_ status: Int) {
		UserDefaults.standard.set(status, forKey: UserDefaultsKeys.userStatus)
		delegate?.didSelectStatus(status)
	}
}
