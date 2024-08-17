//
//  FriendsCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation
import UIKit

class FriendsCoordinator: Coordinator {
	var viewModel: FriendsListViewModel!
	private var friendsListViewController: FriendsListViewController!
    
	override func start() {
		let status = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userStatus)
		setupViewModel(for: status)
        
		friendsListViewController = FriendsListViewController()
		friendsListViewController.viewModel = viewModel
		add(childController: friendsListViewController)
        
		// 開始獲取朋友列表
		fetchFriendsList()
	}
    
	private func setupViewModel(for status: Int) {
		// 根據狀態創建適當的數據源
		let dataSources: [DataSourceStrategy]
		switch status {
		case 1:
			dataSources = [APIDataSource(endpoint: .noFriends)]
		case 2:
			dataSources = [APIDataSource(endpoint: .friend1), APIDataSource(endpoint: .friend2)]
		case 3:
			dataSources = [APIDataSource(endpoint: .friendWithInvites)]
		default:
			fatalError("無效的狀態")
		}
        
		// 使用數據源創建 ViewModel
		viewModel = FriendsListViewModel(dataSources: dataSources)
	}
    
	private func fetchFriendsList() {
		// 調用 ViewModel 的方法來獲取朋友列表
		viewModel.fetchAndCombineFriendsList()
	}
}
