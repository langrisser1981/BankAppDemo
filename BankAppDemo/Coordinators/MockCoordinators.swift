//
//  MockCoordinators.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation
import SnapKit
import UIKit

// MARK: - MoneyCoordinator

// 金錢頁面
class MoneyCoordinator: Coordinator {
	override func start() {
		let viewController = MockViewController(title: "錢錢", imageName: "icTabbarHomeOff")
		add(childController: viewController)
	}
}

// MARK: - AccountingCoordinator

// 記帳頁面
class AccountingCoordinator: Coordinator {
	override func start() {
		let viewController = MockViewController(title: "記帳", imageName: "icTabbarManageOff")
		add(childController: viewController)
	}
}

// MARK: - SettingsCoordinator

// 設定頁面
class SettingsCoordinator: Coordinator {
	override func start() {
		let viewController = MockViewController(title: "設定", imageName: "icTabbarSettingOff")
		add(childController: viewController)
	}
}

// MARK: - MockViewController

// 假的 ViewController
class MockViewController: UIViewController {
	private let titleLabel = UILabel()

	init(title: String, imageName: String) {
		super.init(nibName: nil, bundle: nil)
		self.title = title
		tabBarItem.image = UIImage(named: imageName)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
	}

	private func setupUI() {
		// 設置標題標籤
		titleLabel.text = title
		view.addSubview(titleLabel)

		// 使用 SnapKit 進行約束設置
		titleLabel.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
}
