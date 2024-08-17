//
//  NavigationCoordinator.swift
//
//  Created by 程信傑 on 2023/3/23.
//

import Foundation
import UIKit

class NavigationCoordinator: Coordinator {
	private lazy var containerNavController: UINavigationController = {
		let navController = UINavigationController()
		navController.navigationBar.isHidden = true // 關閉navigation bar

		// iOS15以上，使用 UINavigationBarAppearance 調整 navigationBar 樣式。
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor.clear
		appearance.shadowColor = .clear
		navController.navigationBar.scrollEdgeAppearance = appearance
		navController.navigationBar.standardAppearance = appearance

		return navController
	}()

	var currentViewController: UIViewController? {
		containerNavController.visibleViewController
	}

	override func start() {
		add(childController: containerNavController)
	}

	func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		containerNavController.setViewControllers(viewControllers, animated: animated)
	}

	func pushViewController(_ viewController: UIViewController, animated: Bool) {
		containerNavController.pushViewController(viewController, animated: animated)
	}

	func popViewController(animated: Bool) -> UIViewController? {
		containerNavController.popViewController(animated: animated)
	}

	func popToRootViewController(animated: Bool) -> [UIViewController]? {
		containerNavController.popToRootViewController(animated: animated)
	}

	func present(
		_ page: UIViewController,
		animated: Bool = true,
		asStyle style: UIModalPresentationStyle = .overFullScreen,
		completion: (() -> Void)? = nil
	) {
		/*
		 注意樣式設定
		 .fullScreen,全螢幕顯示頁面，但底下會墊一個灰色背景，沒有辦法看見底下的內容
		 .overFullScreen,全螢幕顯示頁面，但底下是透明的，所以如果顯示的頁面是半透明，就可以看見原本底下的內容
		 */
		page.modalPresentationStyle = style // 預設以全螢幕且底下透明的樣式顯示內容
		present(page, animated: animated) {
			completion?()
		}
	}

	override func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
		super.dismiss(animated: animated) {
			completion?()
		}
	}
}
