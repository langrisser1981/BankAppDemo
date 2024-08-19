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

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		configureDataSource()
		bindViewModel()
	}

	// 設定畫面元件與排版
	private func setupUI() {
		// 新增元件到畫面
		view.addSubview(userInfoStackView)
		view.addSubview(searchBar)
		view.addSubview(tableView)

		// 排版
		userInfoStackView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.height.equalTo(44)
		}

		searchBar.snp.makeConstraints { make in
			make.top.equalTo(userInfoStackView.snp.bottom).offset(20)
			make.left.right.equalToSuperview()
		}

		tableView.snp.makeConstraints { make in
			make.top.equalTo(searchBar.snp.bottom)
			make.left.right.bottom.equalToSuperview()
		}
		// tableView.refreshControl = refreshControl
		tableView.addSubview(refreshControl)

		// 右上角新增一個登出按鈕
		setupLogoutButton()

		let label = UILabel.createWithBubble(text: "Your Text", bubbleNumber: 5)
		view.addSubview(label)

		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalTo(150)
			make.height.equalTo(40)
		}

		// 更新泡泡中的数字
		label.setBubbleNumber(10) // 将泡泡内的数字设置为10
		label.setBubbleNumber(0) // 将数字设置为0时，泡泡将隐藏
		label.setBubbleNumber(150) // 将泡泡内的数字设置为 150, 泡泡将显示 "99+"
	}

	// 設定 diffable data source
	private func configureDataSource() {
		dataSource = DataSource(tableView: tableView) { tableView, indexPath, friend -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
			cell.textLabel?.text = friend.name
			return cell
		}
	}

	// 綁定 ViewModel，訂閱使用者資料與朋友清單
	private func bindViewModel() {
		// 使用者資料
		viewModel.$user
			.receive(on: DispatchQueue.main)
			.sink { [weak self] user in
				if user != nil {
					self?.updateUIWithUserData()
				}
			}
			.store(in: &cancellables)

		// 朋友清單
		viewModel.$filteredFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] friends in
				self?.applySnapshot(with: friends)
			}
			.store(in: &cancellables)
	}

	// 更新 UI 以顯示使用者資料
	private func updateUIWithUserData() {
		if let user = viewModel.user {
			let nameLabel = userInfoStackView.arrangedSubviews[0] as? UILabel
			let kokoidLabel = userInfoStackView.arrangedSubviews[1] as? UILabel

			nameLabel?.text = "名稱：\(user.name)"
			kokoidLabel?.text = "KoKo ID：\(user.kokoid)"
		}
	}

	// 當朋友清單資料更新時，套用新的快照到資料來源
	private func applySnapshot(with friends: [Friend]) {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(friends)
		dataSource.apply(snapshot, animatingDifferences: true) {
			self.refreshControl.endRefreshing()
		}
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

	// 登出按鈕被按下
	@objc private func logoutButtonTapped() {
		delegate?.didRequestLogout(self)
	}

	// 觸發下拉列表更新資料
	@objc private func refreshFriendsList() {
		delegate?.didRequestRefresh(self)
	}

	// MARK: - 下面是表格相關的設定

	// 定義 diffable data source 類型，支援顯示朋友的資料，包含是否優先顯示，個人圖像，名稱
	private typealias DataSource = UITableViewDiffableDataSource<Section, Friend>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>
	// 定義朋友清單的區段
	private enum Section {
		case main
	}

	// 代表朋友清單的資料來源
	private var dataSource: DataSource!

	// MARK: - 下面是元件建立的相關程式碼

	// 朋友清單
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
		return tableView
	}()

	// 搜尋列，用來根據姓名過濾朋友列表
	private lazy var searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "想轉一筆給誰呢?"
		searchBar.delegate = self
		return searchBar
	}()

	// 登出按鈕，用來模擬回到首頁，方便重選要打哪個後端
	private lazy var logoutButton: UIButton = {
		let button = UIButton.createCustomButton(title: "登出", tag: 0)
		button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
		return button
	}()

	// 重新整理控制，下拉會根據目前選擇的後端，重新抓取一次朋友清單
	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		// refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(refreshFriendsList), for: .valueChanged)
		return refreshControl
	}()

	// 使用者資料區塊，會訂閱資料模型，顯示現在的使用者名稱與kokoID
	private lazy var userInfoStackView: UIStackView = {
		let nameLabel = UILabel()
		nameLabel.font = .systemFont(ofSize: 16, weight: .medium)

		let kokoidLabel = UILabel()
		kokoidLabel.font = .systemFont(ofSize: 14, weight: .regular)

		let stackView = UIStackView.create(
			arrangedSubviews: [nameLabel, kokoidLabel],
			axis: .horizontal,
			spacing: 10,
			alignment: .center,
			distribution: .fillEqually
		)
		stackView.backgroundColor = .systemGray6
		stackView.layer.cornerRadius = 8
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
		return stackView
	}()
}

// MARK: UISearchBarDelegate

extension FriendsViewController: UISearchBarDelegate {
	// 搜尋列的委派方法，用來根據姓名過濾朋友列表
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.filterFriends(with: searchText)
	}
}
