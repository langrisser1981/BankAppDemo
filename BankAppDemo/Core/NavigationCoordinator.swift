//
//  NavigationCoordinator.swift
//
//  Created by 程信傑 on 2023/3/23.
//

import Foundation
import UIKit

class NavigationCoordinator: Coordinator {
	// 建立一個自定義的 UINavigationController
	private lazy var containerNavController: UINavigationController = {
		let navController = UINavigationController()
		navController.navigationBar.isHidden = true // 隱藏導覽列

		// 針對 iOS 15 以上版本，設定導覽列外觀
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor.clear
		appearance.shadowColor = .clear
		navController.navigationBar.scrollEdgeAppearance = appearance
		navController.navigationBar.standardAppearance = appearance

		return navController
	}()

	// 取得目前可見的視圖控制器
	var currentViewController: UIViewController? {
		containerNavController.visibleViewController
	}

	// 啟動協調器
	override func start() {
		add(childController: containerNavController)
	}

	// 設定視圖控制器堆疊
	func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		containerNavController.setViewControllers(viewControllers, animated: animated)
	}

	// 推入新的視圖控制器
	func pushViewController(_ viewController: UIViewController, animated: Bool) {
		containerNavController.pushViewController(viewController, animated: animated)
	}

	// 彈出最上層的視圖控制器
	func popViewController(animated: Bool) -> UIViewController? {
		containerNavController.popViewController(animated: animated)
	}

	// 彈出到根視圖控制器
	func popToRootViewController(animated: Bool) -> [UIViewController]? {
		containerNavController.popToRootViewController(animated: animated)
	}

	// 呈現新的視圖控制器
	func present(
		_ page: UIViewController,
		animated: Bool = true,
		asStyle style: UIModalPresentationStyle = .overFullScreen,
		completion: (() -> Void)? = nil
	) {
		/*
		 注意呈現樣式設定：
		 .fullScreen：全螢幕顯示頁面，底下會有灰色背景，無法看見原本的內容
		 .overFullScreen：全螢幕顯示頁面，底下是透明的，如果新頁面是半透明的，可以看見原本的內容
		 */
		page.modalPresentationStyle = style // 預設以全螢幕且底下透明的樣式顯示內容
		present(page, animated: animated) {
			completion?()
		}
	}

	// 關閉當前呈現的視圖控制器
	override func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
		super.dismiss(animated: animated) {
			completion?()
		}
	}
}
