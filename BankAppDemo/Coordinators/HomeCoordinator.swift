//
//  HomeCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import Foundation
import UIKit

// MARK: - HomeCoordinatorDelegate

protocol HomeCoordinatorDelegate: AnyObject {
	func didRequestLogout(_ coordinator: HomeCoordinator)
}

// MARK: - HomeCoordinator

class HomeCoordinator: TabCoordinator {
	weak var delegate: HomeCoordinatorDelegate?

	// 標籤對應的子畫面
	private var moneyCoordinator: MockCoordinator?
	private var friendsCoordinator: FriendsCoordinator?
	private var paymentCoordinator: PaymentCoordinator?
	private var accountingCoordinator: MockCoordinator?
	private var settingsCoordinator: MockCoordinator?

	override func start() {
		super.start()

		// 初始化每個子畫面
		moneyCoordinator = MockCoordinator(screenTitle: "錢錢")
		moneyCoordinator?.configureTabBarItem(title: "錢錢", image: UIImage(named: "icTabbarProductsOff"), tag: 0)
		friendsCoordinator = FriendsCoordinator()
		friendsCoordinator?.configureTabBarItem(title: "朋友", image: UIImage(named: "icTabbarFriendsOn"), tag: 1)
		friendsCoordinator?.delegate = self
		paymentCoordinator = PaymentCoordinator()
		accountingCoordinator = MockCoordinator(screenTitle: "記帳")
		accountingCoordinator?.configureTabBarItem(title: "記帳", image: UIImage(named: "icTabbarManageOff"), tag: 3)
		settingsCoordinator = MockCoordinator(screenTitle: "設定")
		settingsCoordinator?.configureTabBarItem(title: "設定", image: UIImage(named: "icTabbarSettingOff"), tag: 4)
		let emptyVC = UIViewController()
		let emptyImage = UIImage()
		emptyVC.configureTabBarItem(title: "emptyVC", image: UIImage(named: "emptyVC"), tag: 2)

		// 建立一個包含所有子畫面的陣列
		let coordinators: [UIViewController] = [
			moneyCoordinator,
			friendsCoordinator,
			emptyVC, // 因為中央要用自訂按鈕，所以這裡等於是佔位
			accountingCoordinator,
			settingsCoordinator
		].compactMap { $0 }

		// 設定標籤列對應的子畫面
		setTabBarViewControllers(coordinators, animated: false)
		tabBar.items?[2].isEnabled = false

		// 設定標籤列外觀
		setupTabBarAppearance()

		// 建立自訂支付按鈕
		createCustomPaymentButton()

		// 將朋友頁設為預設的啟動頁面
		selectTab(at: 1)

		// 設定標籤列委派
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

		tabBar.backgroundImage = UIImage(named: "imgTabbarBg")?.withRenderingMode(.alwaysOriginal)
		tabBar.isTranslucent = true

		// 設定標籤列陰影
		// tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
		// tabBar.layer.shadowRadius = 32
		// tabBar.layer.shadowColor = UIColor.lightInk006.cgColor
		// tabBar.layer.shadowOpacity = 1
	}

	private func createCustomPaymentButton() {
		// 建立容器視圖
		let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 85, height: 68))
		containerView.center = CGPoint(x: tabBar.bounds.midX, y: tabBar.bounds.midY - 5)

		// 自訂按鈕
		let customPaymentButton = UIButton(type: .custom)
		customPaymentButton.frame = containerView.bounds
		customPaymentButton.setImage(UIImage(named: "icTabbarHomeOff"), for: .normal)
		customPaymentButton.adjustsImageWhenHighlighted = false // 點擊按鈕時圖片不要高亮
		customPaymentButton.configuration?.automaticallyUpdateForSelection = false
		// customPaymentButton.layer.cornerRadius = 36
		// customPaymentButton.layer.borderColor = UIColor.neutralWhite.cgColor
		// customPaymentButton.layer.borderWidth = 5
		// 將按鈕裁切成圓形
		customPaymentButton.clipsToBounds = true
		customPaymentButton.layer.cornerRadius = 34

		// 自訂標籤文字
		let label = UILabel()
		label.text = "收款碼"
		// label.font = EMFontStyle.pingFangMediumWithSize12.value
		label.textColor = .white
		label.sizeToFit()
		label.center = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.maxY + 10)

		containerView.addSubview(customPaymentButton)
		// containerView.addSubview(label)
		tabBar.addSubview(containerView)
	}

	@objc private func didTapPaymentButton() {
		// 處理支付按鈕點擊事件
		print("支付按鈕被點擊")
		// 使用可選綁定來安全地解包 paymentCoordinator
		if let paymentCoordinator = paymentCoordinator {
			// 設定委派，回應關閉按鈕被點擊
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

// MARK: FriendsCoordinatorDelegate

extension HomeCoordinator: FriendsCoordinatorDelegate {
	func didRequestLogout(_ coordinator: FriendsCoordinator) {
		delegate?.didRequestLogout(self)
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
