//
//  TabCoordinator.swift
//
//  Created by 程信傑 on 2023/3/23.
//

import Foundation
import UIKit

class TabCoordinator: NavigationCoordinator {
	let embeddedTabBarController = UITabBarController()

	override func start() {
		super.start()
		embeddedNavigationController.setViewControllers([embeddedTabBarController], animated: false)
	}
}
