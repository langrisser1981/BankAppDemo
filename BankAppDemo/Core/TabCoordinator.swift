//
//  TabCoordinator.swift
//
//  Created by 程信傑 on 2023/3/23.
//

import Foundation
import UIKit

// MARK: - TabCoordinator

class TabCoordinator: NavigationCoordinator {
	// 宣告一個私有的 UITabBarController 實例
	private lazy var containerTabBarController: UITabBarController = .init()

	// 取得 tabBar 的唯讀屬性
	var tabBar: UITabBar {
		containerTabBarController.tabBar
	}

	// 覆寫 start 方法，初始化 TabBarController
	override func start() {
		super.start()
		let tabBarController = containerTabBarController
		setViewControllers([tabBarController], animated: false)
	}

	// 設定 TabBarController 的子視圖控制器
	func setTabBarViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		containerTabBarController.setViewControllers(viewControllers, animated: animated)
	}

	// 設定 TabBarController 的委派
	func setTabBarDelegate(_ delegate: UITabBarControllerDelegate) {
		containerTabBarController.delegate = delegate
	}

	// 取得目前選中的標籤頁面
	var selectedTab: UIViewController? {
		containerTabBarController.selectedViewController
	}

	// 根據索引選擇特定的標籤頁面
	func selectTab(at index: Int) {
		containerTabBarController.selectedIndex = index
	}
}

// UIViewController 的擴展，用於設定標籤列項目
extension UIViewController {
	// 設定標籤列項目的標題、圖示和標籤
	func configureTabBarItem(title: String?, image: UIImage?, tag: Int) {
		tabBarItem = UITabBarItem(title: title, image: image?.withRenderingMode(.alwaysOriginal), tag: tag)
	}
}
