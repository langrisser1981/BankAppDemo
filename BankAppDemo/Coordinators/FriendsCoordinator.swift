//
//  FriendsCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation
import UIKit

// MARK: - FriendsCoordinator

class FriendsCoordinator: Coordinator {
	override func start() {
		let friendsViewController = FriendsViewController()
		add(childController: friendsViewController)
	}
}
