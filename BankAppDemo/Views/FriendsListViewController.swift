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

	// 定義 diffable data source 類型
	private typealias DataSource = UITableViewDiffableDataSource<Section, Friend>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>

	// 定義表格的區段
	private enum Section {
		case main
	}

	// 懶加載表格視圖
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
		return tableView
	}()

	// 懶加載搜尋欄
	private lazy var searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "搜尋朋友"
		searchBar.delegate = self
		return searchBar
	}()

	// 數據源屬性
	private var dataSource: DataSource!

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		configureDataSource()
		bindViewModel()
	}

	// 設置 UI 元素
	private func setupUI() {
		view.addSubview(searchBar)
		view.addSubview(tableView)

		searchBar.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.left.right.equalToSuperview()
		}

		tableView.snp.makeConstraints { make in
			make.top.equalTo(searchBar.snp.bottom)
			make.left.right.bottom.equalToSuperview()
		}
	}

	// 配置 diffable data source
	private func configureDataSource() {
		dataSource = DataSource(tableView: tableView) { tableView, indexPath, friend -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
			cell.textLabel?.text = friend.name
			return cell
		}
	}

	// 綁定 ViewModel
	private func bindViewModel() {
		// 訂閱 ViewModel 的 filteredFriends 屬性
		viewModel.$filteredFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] friends in
				self?.applySnapshot(with: friends)
			}
			.store(in: &cancellables)
	}

	// 應用新的快照到數據源
	private func applySnapshot(with friends: [Friend]) {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(friends)
		dataSource.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: UISearchBarDelegate

extension FriendsListViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.filterFriends(with: searchText)
	}
}
