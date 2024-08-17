//
//  TabCoordinator.swift
//
//  Created by 程信傑 on 2023/3/23.
//

import Foundation
import UIKit

class TabCoordinator: NavigationCoordinator {
	private lazy var containerTabBarController: UITabBarController = .init()

	// 獲取tabBar
	var tabBar: UITabBar {
		containerTabBarController.tabBar
	}

	override func start() {
		super.start()
		let tabBarController = containerTabBarController // 在這裡實體化
		setViewControllers([tabBarController], animated: false)
	}

	// MARK: - 設置標籤欄視圖控制器

	func setTabBarViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		containerTabBarController.setViewControllers(viewControllers, animated: animated)
	}

	// MARK: - 設置標籤欄委託

	func setTabBarDelegate(_ delegate: UITabBarControllerDelegate) {
		containerTabBarController.delegate = delegate
	}

	// MARK: - 獲取選中的標籤

	var selectedTab: UIViewController? {
		containerTabBarController.selectedViewController
	}

	// MARK: - 選中標籤

	func selectTab(at index: Int) {
		containerTabBarController.selectedIndex = index
	}
}
