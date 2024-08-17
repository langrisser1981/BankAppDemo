//
//  HomeCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import Foundation
import UIKit

// MARK: - HomeCoordinator

class HomeCoordinator: TabCoordinator {
	private let status: Int
	// 添加子協調器的屬性以保持強引用
	private var moneyCoordinator: MoneyCoordinator?
	private var friendsCoordinator: FriendsCoordinator?
	private var paymentCoordinator: PaymentCoordinator?
	private var accountingCoordinator: AccountingCoordinator?
	private var settingsCoordinator: SettingsCoordinator?

	init(status: Int) {
		self.status = status
		super.init()
	}

	override func setupSubscriptions() {
		print("開始取得使用者資訊")
	}

	override func start() {
		super.start()

		// 初始化子協調器並保存引用
		moneyCoordinator = MoneyCoordinator()
		friendsCoordinator = FriendsCoordinator(status: 3)
		accountingCoordinator = AccountingCoordinator()
		settingsCoordinator = SettingsCoordinator()
		paymentCoordinator = PaymentCoordinator()

		// 創建一個包含所有子協調器的陣列
		let coordinators: [UIViewController] = [
			moneyCoordinator,
			friendsCoordinator,
			UIViewController(), // 因為中央要用自訂按鈕，所以這邊等於是佔位
			accountingCoordinator,
			settingsCoordinator
		].compactMap { $0 }

		// 設置標籤欄視圖控制器
		setTabBarViewControllers(coordinators, animated: false)

		// 設置標籤欄外觀
		setupTabBarAppearance()

		// 創建自訂支付按鈕
		createCustomPaymentButton()

		// 將朋友頁設為預設的啟動頁面
		selectTab(at: 1)

		// 設置標籤欄委託
		setTabBarDelegate(self)
	}

	private func setupTabBarAppearance() {
		let appearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground()
		// appearance.backgroundColor = .neutralWhite

		// 移除陰影底線
		appearance.shadowColor = .clear

		tabBar.standardAppearance = appearance
		if #available(iOS 15.0, *) {
			tabBar.scrollEdgeAppearance = appearance
		}

		// 設定標籤列陰影
		tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
		tabBar.layer.shadowRadius = 32
		// tabBar.layer.shadowColor = UIColor.lightInk006.cgColor
		tabBar.layer.shadowOpacity = 1
	}

	private func createCustomPaymentButton() {
		// 創建容器視圖
		let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
		containerView.center = CGPoint(x: tabBar.bounds.midX, y: tabBar.bounds.midY - 15)

		// 自訂按鈕
		let customPaymentButton = UIButton(type: .custom)
		customPaymentButton.frame = containerView.bounds
		customPaymentButton.setImage(UIImage(named: "qrcode_white_normal"), for: .normal)
		customPaymentButton.configuration?.automaticallyUpdateForSelection = false
		// customPaymentButton.backgroundColor = .easyCardBlue
		customPaymentButton.layer.cornerRadius = 36
		// customPaymentButton.layer.borderColor = UIColor.neutralWhite.cgColor
		customPaymentButton.layer.borderWidth = 5
		customPaymentButton.addTarget(self, action: #selector(didTapPaymentButton), for: .touchUpInside)

		// 自訂標籤文字
		let label = UILabel()
		label.text = "收款碼"
		// label.font = EMFontStyle.pingFangMediumWithSize12.value
		label.textColor = .white
		label.sizeToFit()
		label.center = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.maxY + 10)

		containerView.addSubview(customPaymentButton)
		containerView.addSubview(label)
		tabBar.addSubview(containerView)
	}

	@objc private func didTapPaymentButton() {
		// 處理支付按鈕點擊事件
		print("支付按鈕被點擊")
		// 使用可選綁定來安全地解包 paymentCoordinator
		if let paymentCoordinator = paymentCoordinator {
			// 設置委派
			paymentCoordinator.delegate = self
			// 使用 present 方法顯示支付頁面
			present(paymentCoordinator)
		} else {
			print("錯誤：paymentCoordinator 未初始化")
		}
	}
}

// MARK: PaymentCoordinatorDelegate

extension HomeCoordinator: PaymentCoordinatorDelegate {
	func paymentCoordinatorDidFinish(_ coordinator: PaymentCoordinator) {
		// 關閉支付頁面
		dismiss(animated: true)
	}
}

// MARK: UITabBarControllerDelegate

extension HomeCoordinator: UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		// 因為第三個標籤是自訂按鈕，所以禁用原本的標籤
		let index = tabBarController.viewControllers?.firstIndex(of: viewController) // 取得目前點擊標籤所對應的索引
		if index == 2 {
			return false // 禁用標籤選擇
		}

		return true
	}
}
