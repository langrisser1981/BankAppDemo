//
//  PaymentCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation
import SnapKit
import UIKit

// MARK: - PaymentCoordinatorDelegate

protocol PaymentCoordinatorDelegate: AnyObject {
	func paymentCoordinatorDidFinish(_ coordinator: PaymentCoordinator)
}

// MARK: - PaymentCoordinator

// 支付頁面
class PaymentCoordinator: Coordinator {
	weak var delegate: PaymentCoordinatorDelegate?

	override func start() {
		let viewController = PaymentViewController()
		viewController.delegate = self
		add(childController: viewController)
	}

	func closePaymentView() {
		// 通知委派支付頁面已關閉
		delegate?.paymentCoordinatorDidFinish(self)
	}
}

// MARK: PaymentViewControllerDelegate

extension PaymentCoordinator: PaymentViewControllerDelegate {
	func paymentViewControllerDidRequestClose(_ viewController: PaymentViewController) {
		closePaymentView()
	}
}
