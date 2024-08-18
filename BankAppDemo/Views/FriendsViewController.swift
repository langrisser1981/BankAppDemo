//
//  FriendsViewController.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/816.
//

import Combine
import SnapKit
import UIKit

// MARK: - FriendsViewControllerDelegate

protocol FriendsViewControllerDelegate: AnyObject {
	func didRequestLogout(_ viewController: FriendsViewController)
	func didRequestRefresh(_ viewController: FriendsViewController)
}

// MARK: - FriendsViewController

class FriendsViewController: UIViewController {
	weak var delegate: FriendsViewControllerDelegate?
	private let viewModel: FriendsViewModel

	init(viewModel: FriendsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private var cancellables = Set<AnyCancellable>()

	// 定義 diffable data source 類型
	private typealias DataSource = UITableViewDiffableDataSource<Section, Friend>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>

	// 定義表格的區段
	private enum Section {
		case main
	}

	// 延遲初始化表格視圖
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
		return tableView
	}()

	// 延遲初始化搜尋列
	private lazy var searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "搜尋朋友"
		searchBar.delegate = self
		return searchBar
	}()

	// 資料來源屬性
	private var dataSource: DataSource!

	// 添加登出按鈕
	private lazy var logoutButton: UIButton = {
		let button = UIButton.createCustomButton(title: "登出", tag: 0)
		button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
		return button
	}()

	// 添加重新整理控制
	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refreshFriendsList), for: .valueChanged)
		return refreshControl
	}()

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
		tableView.refreshControl = refreshControl
		setupLogoutButton()
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
		viewModel.$user
			.receive(on: DispatchQueue.main)
			.sink { [weak self] user in
				if user != nil {
					self?.updateUIWithUserData()
				}
			}
			.store(in: &cancellables)
		viewModel.$filteredFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] friends in
				self?.applySnapshot(with: friends)
				self?.refreshControl.endRefreshing()
			}
			.store(in: &cancellables)
	}

	// 更新 UI 以顯示使用者資料
	private func updateUIWithUserData() {
		// 更新 UI 以顯示使用者資料
	}

	// 用新的快照到資料來源
	private func applySnapshot(with friends: [Friend]) {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(friends)
		dataSource.apply(snapshot, animatingDifferences: true)
	}

	private func setupLogoutButton() {
		view.addSubview(logoutButton)
		logoutButton.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.trailing.equalToSuperview().offset(-20)
			make.width.equalTo(80)
			make.height.equalTo(40)
		}
	}

	@objc private func logoutButtonTapped() {
		delegate?.didRequestLogout(self)
	}

	@objc private func refreshFriendsList() {
		delegate?.didRequestRefresh(self)
	}
}

// MARK: UISearchBarDelegate

extension FriendsViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.filterFriends(with: searchText)
	}
}
