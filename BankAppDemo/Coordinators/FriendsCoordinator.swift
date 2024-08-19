//
//  FriendsCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Combine
import Foundation
import UIKit

// MARK: - FriendsCoordinatorDelegate

protocol FriendsCoordinatorDelegate: AnyObject {
	func didRequestLogout(_ coordinator: FriendsCoordinator)
}

// MARK: - FriendsCoordinator

class FriendsCoordinator: Coordinator {
	weak var delegate: FriendsCoordinatorDelegate?
	private let viewModel: FriendsViewModel
	private var friendsViewController: FriendsViewController!

	init(viewModel: FriendsViewModel = FriendsViewModel()) {
		self.viewModel = viewModel
		super.init()
	}

	override func start() {
		// 初始化 ViewController
		friendsViewController = FriendsViewController(viewModel: viewModel)
		friendsViewController.delegate = self
		add(childController: friendsViewController)

		fetchFriendsBasedOnUserStatus()
	}

	/// 根據使用者狀態取得朋友列表
	private func fetchFriendsBasedOnUserStatus() {
		let status = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userStatus)
		let dataSources = getDataSourcesForStatus(status)
		viewModel.fetchFriends(from: dataSources)
	}

	/// 根據狀態取得對應的資料來源
	/// - Parameter status: 想要呼叫的後端類型
	/// - Returns: 對應的資料來源陣列
	func getDataSourcesForStatus(_ status: Int) -> [APIDataSource] {
		let endpoints: [APIService.APIEndpoint]

		switch status {
		case 1:
			endpoints = [.noFriends]
		case 2:
			endpoints = [.friend1, .friend2]
		case 3:
			endpoints = [.friendWithInvites]
		default:
			endpoints = []
		}

		return endpoints.map { APIDataSource(endpoint: $0) }
	}
}

// MARK: FriendsViewControllerDelegate

extension FriendsCoordinator: FriendsViewControllerDelegate {
	func didRequestLogout(_ viewController: FriendsViewController) {
		delegate?.didRequestLogout(self)
	}

	func didRequestRefresh(_ viewController: FriendsViewController) {
		fetchFriendsBasedOnUserStatus()
	}
}
