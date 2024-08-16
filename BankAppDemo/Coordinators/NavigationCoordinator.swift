//
//  NavigationCoordinator.swift
//
//  Created by 程信傑 on 2023/3/23.
//

import Foundation
import UIKit

class NavigationCoordinator: Coordinator {
	let embeddedNavigationController = UINavigationController()

	var currentViewController: UIViewController? {
		embeddedNavigationController.visibleViewController
	}

	override func start() {
		embeddedNavigationController.navigationBar.isHidden = true // 關閉navigation bar

		// iOS15以上，使用 UINavigationBarAppearance 調整 navigationBar 樣式。
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor.clear
		appearance.shadowColor = .clear
		embeddedNavigationController.navigationBar.scrollEdgeAppearance = appearance
		embeddedNavigationController.navigationBar.standardAppearance = appearance

		add(childController: embeddedNavigationController)
	}

	func navigateToPage(_ page: UIViewController, animated: Bool = true) {
		embeddedNavigationController.pushViewController(page, animated: animated)
	}

	func navigateBack(animated: Bool = true) {
		embeddedNavigationController.popViewController(animated: animated)
	}

	func navigateToRoot(animated: Bool = true) {
		embeddedNavigationController.popToRootViewController(animated: animated)
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
