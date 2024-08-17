//
//  FriendsListViewController.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Combine
import UIKit

// MARK: - FriendsListViewController

class FriendsListViewController: UIViewController {
	var viewModel: FriendsListViewModel!
	private var cancellables = Set<AnyCancellable>()

	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
		tableView.dataSource = self
		tableView.delegate = self
		return tableView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindViewModel()
	}

	private func setupUI() {
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}

	private func bindViewModel() {
		// 訂閱 ViewModel 的 combinedFriends 屬性
		viewModel.$combinedFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)
	}
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension FriendsListViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.combinedFriends.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
		let friend = viewModel.combinedFriends[indexPath.row]
		cell.textLabel?.text = friend.name
		return cell
	}
}
