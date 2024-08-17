//
//  PaymentViewController.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation
import SnapKit
import UIKit

// MARK: - PaymentViewControllerDelegate

protocol PaymentViewControllerDelegate: AnyObject {
	func paymentViewControllerDidRequestClose(_ viewController: PaymentViewController)
}

// MARK: - PaymentViewController

class PaymentViewController: UIViewController {
	weak var delegate: PaymentViewControllerDelegate?
	private let titleLabel = UILabel()
	private let closeButton = UIButton(type: .system)

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
	}

	private func setupUI() {
		// 設置標題標籤
		titleLabel.text = "支付頁面"
		view.addSubview(titleLabel)

		// 設置關閉按鈕
		closeButton.setTitle("關閉", for: .normal)
		closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
		view.addSubview(closeButton)

		titleLabel.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}

		closeButton.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.trailing.equalToSuperview().offset(-20)
		}
	}

	@objc private func closeTapped() {
		delegate?.paymentViewControllerDidRequestClose(self)
	}
}
