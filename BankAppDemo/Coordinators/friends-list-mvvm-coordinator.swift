// MoneyCoordinator.swift
import UIKit

// MARK: - MoneyCoordinator

class MoneyCoordinator: Coordinator {
	override func start() {
		let moneyVC = UIViewController() // Replace with your actual MoneyViewController
		moneyVC.title = "錢錢"
		moneyVC.tabBarItem = UITabBarItem(title: "錢錢", image: UIImage(systemName: "dollarsign.circle"), tag: 0)
	}
}

// FriendsCoordinator.swift
import UIKit

// MARK: - FriendsCoordinator

class FriendsCoordinator: Coordinator {
	override func start() {
		let friendsVC = FriendsViewController()
		friendsVC.title = "朋友"
		friendsVC.tabBarItem = UITabBarItem(title: "朋友", image: UIImage(systemName: "person.2"), tag: 1)
	}
}

// PaymentCoordinator.swift
import UIKit

// MARK: - PaymentCoordinator

class PaymentCoordinator: Coordinator {
	override func start() {
		let paymentVC = UIViewController() // Replace with your actual PaymentViewController
		paymentVC.title = "支付"
		paymentVC.tabBarItem = UITabBarItem(title: "支付", image: UIImage(systemName: "creditcard"), tag: 2)
	}
}

// AccountingCoordinator.swift
import UIKit

// MARK: - AccountingCoordinator

class AccountingCoordinator: Coordinator {
	override func start() {
		let accountingVC = UIViewController() // Replace with your actual AccountingViewController
		accountingVC.title = "記帳"
		accountingVC.tabBarItem = UITabBarItem(title: "記帳", image: UIImage(systemName: "book"), tag: 3)
	}
}

// SettingsCoordinator.swift
import UIKit

// MARK: - SettingsCoordinator

class SettingsCoordinator: Coordinator {
	override func start() {
		let settingsVC = UIViewController() // Replace with your actual SettingsViewController
		settingsVC.title = "設定"
		settingsVC.tabBarItem = UITabBarItem(title: "設定", image: UIImage(systemName: "gear"), tag: 4)
	}
}
