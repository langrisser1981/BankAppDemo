//
//  LoginViewController.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Foundation
import SnapKit
import UIKit

// MARK: - LoginViewControllerDelegate

protocol LoginViewControllerDelegate: AnyObject {
	func didSelectStatus(_ status: Int)
}

// MARK: - LoginViewController

class LoginViewController: UIViewController {
	weak var delegate: LoginViewControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	private func setupUI() {
		// 創建三個按鈕
		let button1 = createButton(title: "狀態 1", tag: 1)
		let button2 = createButton(title: "狀態 2", tag: 2)
		let button3 = createButton(title: "狀態 3", tag: 3)

		// 創建一個垂直堆疊視圖
		let stackView = UIStackView.create(
			arrangedSubviews: [button1, button2, button3],
			axis: .vertical,
			spacing: 20,
			alignment: .center
		)
		view.addSubview(stackView)

		stackView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}

		// 設置按鈕的佈局
		for button in [button1, button2, button3] {
			button.snp.makeConstraints { make in
				make.width.equalTo(200)
			}
		}
	}

	@objc private func buttonTapped(_ sender: UIButton) {
		delegate?.didSelectStatus(sender.tag)
	}

	// 創建按鈕的輔助方法
	private func createButton(title: String, tag: Int) -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(title, for: .normal)
		button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		button.tag = tag
		return button
	}
}
