//
//  LoginViewController.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import SnapKit
import UIKit

// MARK: - LoginViewControllerDelegate

protocol LoginViewControllerDelegate: AnyObject {
	func didSelectStatus(_ status: Int)
}

// MARK: - LoginViewController

class LoginViewController: UIViewController {
	weak var delegate: LoginViewControllerDelegate?
	private let viewModel: LoginViewModel

	init(viewModel: LoginViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private var cancellables = Set<AnyCancellable>()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindViewModel()
	}

	private func setupUI() {
		view.backgroundColor = .white // 設定背景顏色

		// 建立三個按鈕，更新按鈕文字
		let button1 = createButton(title: "無朋友", tag: 1)
		let button2 = createButton(title: "合併朋友列表", tag: 2)
		let button3 = createButton(title: "含邀請朋友列表", tag: 3)

		// 建立一個垂直堆疊視圖
		let stackView = UIStackView(arrangedSubviews: [button1, button2, button3])
		stackView.axis = .vertical
		stackView.spacing = 20
		stackView.alignment = .center
		view.addSubview(stackView)

		// 設定堆疊視圖的約束
		stackView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}

		// 設定按鈕的約束
		for button in [button1, button2, button3] {
			button.snp.makeConstraints { make in
				make.width.equalTo(200)
				make.height.equalTo(44) // 設定按鈕高度
			}
		}
	}

	private func bindViewModel() {
		viewModel.$user
			.receive(on: DispatchQueue.main)
			.sink { [weak self] user in
				if user != nil {
					self?.updateUIWithUserData()
				}
			}
			.store(in: &cancellables)
	}

	private func updateUIWithUserData() {
		// 更新 UI 以顯示使用者資料
	}

	@objc private func buttonTapped(_ sender: UIButton) {
		delegate?.didSelectStatus(sender.tag)
	}

	// 建立按鈕的輔助方法
	private func createButton(title: String, tag: Int) -> UIButton {
		let button = UIButton.createCustomButton(title: title, tag: tag)
		button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		return button
	}
}
