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

	// MARK: - 排版

	// 設定畫面元件與排版
	private func setupUI() {
		// 設定整個視圖控制器的背景為系統背景色
		view.backgroundColor = .systemBackground

		// 新增元件到畫面
		view.addSubview(main)
		main.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.left.right.bottom.equalToSuperview()
		}
	}

	// MARK: - 資料綁定

	// 設定 diffable data source
	private func configureDataSource() {
		dataSource = DataSource(tableView: tableView) { tableView, indexPath, friend -> UITableViewCell? in
			if friend.status == 0 {
				guard let cell = tableView.dequeueReusableCell(withIdentifier: InvitationCell.reuseIdentifier, for: indexPath) as? InvitationCell else {
					fatalError("無法取得 InvitationCell")
				}
				cell.configure(with: friend)
				return cell
			} else {
				guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseIdentifier, for: indexPath) as? FriendCell else {
					fatalError("無法取得 FriendCell")
				}
				cell.configure(with: friend)
				return cell
			}
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
				// 輸出朋友清單到終端機
				print("朋友清單：")
				friends.forEach { print($0) }
				// 更新頁面標籤列的泡泡數字
				self?.updateFriendsBubble(count: friends.count)
				self?.updateChatBubble(count: 100)
			}
			.store(in: &cancellables)

		// 收到的邀請清單
		viewModel.$receivedInvitations
			.receive(on: DispatchQueue.main)
			.sink { [weak self] invitations in
				self?.applySnapshot(with: invitations)
				// 輸出收到的邀請清單到終端機
				print("邀請清單：")
				invitations.forEach { print($0) }
				// self?.updateChatBubble(count: invitations.count)
			}
			.store(in: &cancellables)

		// 監聽 combinedFriends 的變化，更新畫面顯示狀態
		viewModel.$combinedFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] friends in
				self?.updateContentVisibility(isEmpty: friends.isEmpty)
			}
			.store(in: &cancellables)
	}

	// MARK: - 內部行為，如更新各種介面

	// 當朋友清單資料更新時，套用新的快照到資料來源
	private func applySnapshot(with friends: [Friend]) {
		var snapshot = Snapshot()
		snapshot.appendSections([.invitations, .main])
		let invitations = friends.filter { $0.status == 0 }
		let normalFriends = friends.filter { $0.status != 0 }
		snapshot.appendItems(invitations, toSection: .invitations)
		snapshot.appendItems(normalFriends, toSection: .main)
		dataSource.apply(snapshot, animatingDifferences: true) {
			self.refreshControl.endRefreshing()
		}
	}

	// 更新使用者資料
	private func updateUIWithUserData() {
		if let user = viewModel.user {
			if let mainStack = userInfo.subviews.first as? UIStackView,
			   let leftStack = mainStack.arrangedSubviews.first as? UIStackView,
			   let nameLabel = leftStack.arrangedSubviews.first as? UILabel,
			   let kokoidStack = leftStack.arrangedSubviews.last as? UIStackView,
			   let kokoidLabel = kokoidStack.arrangedSubviews[1] as? UILabel
			{
				nameLabel.text = user.name
				kokoidLabel.text = user.kokoid
			}
		}
	}

	// 更新內容可見性，根據朋友表是否為空來切換顯示
	private func updateContentVisibility(isEmpty: Bool) {
		emptyStateImageView.isHidden = !isEmpty
		friendsContent.isHidden = isEmpty
	}

	// 更新"好友"標籤的泡泡數字
	private func updateFriendsBubble(count: Int) {
		if let stackView = pageTabBar.subviews.first as? UIStackView,
		   let friendsLabel = stackView.arrangedSubviews.first as? UILabel
		{
			friendsLabel.setBubbleNumber(count)
		}
	}

	// 更新"聊天"標籤的泡泡數字
	private func updateChatBubble(count: Int) {
		if let stackView = pageTabBar.subviews.first as? UIStackView,
		   let chatLabel = stackView.arrangedSubviews.last as? UILabel
		{
			chatLabel.setBubbleNumber(count)
		}
	}

	// MARK: - 按鈕事件的處理

	// 登出按鈕被按下
	@objc private func logoutButtonTapped() {
		delegate?.didRequestLogout(self)
	}

	// 觸發下拉列表更新資料
	@objc private func refreshFriendsList() {
		delegate?.didRequestRefresh(self)
	}

	// MARK: - 建立控制元件的宣告

	// 主視圖，包含使用者資訊和內容容器
	private lazy var main: UIView = {
		let container = UIView()
		container.backgroundColor = .systemBackground

		let stackView = UIStackView.create(
			arrangedSubviews: [toolbar, userInfo, contentContainer],
			axis: .vertical,
			spacing: 0,
			alignment: .fill,
			distribution: .fill
		)

		container.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
		}

		return container
	}()

	// 工具列，包含提款、轉帳跟掃描，現在按下掃描會跳回初始頁，方便測試
	private lazy var toolbar: UIView = {
		let container = UIView()
		container.backgroundColor = .systemBackground

		let withdrawButton = createToolbarButton(imageName: "icNavPinkWithdraw")
		let transferButton = createToolbarButton(imageName: "icNavPinkTransfer")
		let scanButton = createToolbarButton(imageName: "icNavPinkScan")
		scanButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)

		let stackView = UIStackView.create(
			arrangedSubviews: [withdrawButton, transferButton, UIView(), scanButton],
			axis: .horizontal,
			spacing: 20,
			alignment: .center,
			distribution: .fill
		)

		container.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
			make.height.equalTo(30)
		}

		return container
	}()

	// 使用者資料，會訂閱資料模型，顯示現在的使用者名稱與kokoID
	private lazy var userInfo: UIView = {
		let container = UIView()
		container.backgroundColor = .systemBackground

		let nameLabel = UILabel()
		nameLabel.font = .systemFont(ofSize: 16, weight: .medium)

		let kokoidPrefixLabel = UILabel()
		kokoidPrefixLabel.font = .systemFont(ofSize: 14, weight: .regular)
		kokoidPrefixLabel.text = "KOKO ID : "

		let kokoidLabel = UILabel()
		kokoidLabel.font = .systemFont(ofSize: 14, weight: .regular)

		let infoButton = createToolbarButton(imageName: "icInfoBackDeepGray")

		let kokoidStack = UIStackView.create(
			arrangedSubviews: [kokoidPrefixLabel, kokoidLabel, infoButton],
			axis: .horizontal,
			spacing: 4,
			alignment: .center,
			distribution: .fill
		)

		let leftStack = UIStackView.create(
			arrangedSubviews: [nameLabel, kokoidStack],
			axis: .vertical,
			spacing: 4,
			alignment: .leading,
			distribution: .fill
		)

		let avatarImageView = UIImageView(image: UIImage(named: "imgFriendsFemaleDefault"))
		avatarImageView.contentMode = .scaleAspectFill
		avatarImageView.clipsToBounds = true
		avatarImageView.layer.cornerRadius = 26

		let mainStack = UIStackView.create(
			arrangedSubviews: [leftStack, avatarImageView],
			axis: .horizontal,
			spacing: 8,
			alignment: .center,
			distribution: .equalSpacing
		)

		container.addSubview(mainStack)
		mainStack.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
			make.height.equalTo(52)
		}

		avatarImageView.snp.makeConstraints { make in
			make.size.equalTo(CGSize(width: 52, height: 52))
		}

		return container
	}()

	// 內容容器視圖，用於切換空狀態和朋友列表
	private lazy var contentContainer: UIView = {
		let container = UIView()
		container.backgroundColor = .systemBackground

		container.addSubview(emptyStateImageView)
		emptyStateImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		container.addSubview(friendsContent)
		friendsContent.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		return container
	}()

	// 空狀態圖片視圖
	private lazy var emptyStateImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "imgFriendsEmpty"))
		imageView.contentMode = .scaleAspectFit
		imageView.isHidden = true
		return imageView
	}()

	// 朋友內容視圖，包含頁面標籤列、搜尋列和朋友清單
	private lazy var friendsContent: UIStackView = {
		let stackView = UIStackView.create(
			arrangedSubviews: [pageTabBar, searchBar, tableView],
			axis: .vertical,
			spacing: 20,
			alignment: .fill,
			distribution: .fill
		)
		stackView.isHidden = true
		return stackView
	}()

	// 頁面標籤列，顯示"好友"和"聊天"兩個選項
	private lazy var pageTabBar: UIView = {
		let container = UIView()
		container.backgroundColor = .systemBackground

		// 建立"好友"標籤
		let friendsLabel = UILabel.createWithBubble(text: "好友", bubbleNumber: 0)
		friendsLabel.textAlignment = .center
		friendsLabel.font = .systemFont(ofSize: 16, weight: .medium)

		// 建立"聊天"標籤
		let chatLabel = UILabel.createWithBubble(text: "聊天", bubbleNumber: 0)
		chatLabel.textAlignment = .center
		chatLabel.font = .systemFont(ofSize: 16, weight: .medium)

		// 建立水平堆疊視圖
		let stackView = UIStackView.create(
			arrangedSubviews: [friendsLabel, chatLabel],
			axis: .horizontal,
			spacing: 20,
			alignment: .center,
			distribution: .equalSpacing
		)

		container.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(8)
			make.left.equalToSuperview().inset(16)
		}

		// 新增底部的粉紅色線條
		let bottomLine = UIView()
		bottomLine.backgroundColor = .hotPink
		container.addSubview(bottomLine)
		bottomLine.snp.makeConstraints { make in
			make.bottom.equalToSuperview()
			make.height.equalTo(2)
			make.width.equalTo(friendsLabel.snp.width)
			make.left.equalTo(friendsLabel)
		}

		return container
	}()

	// 搜尋列，使用者可以輸入姓名，會即時更新朋友列表的顯示
	private lazy var searchBar: UIView = {
		let container = UIView()
		container.backgroundColor = .systemBackground

		// 建立 UISearchBar
		let searchBar = UISearchBar()
		searchBar.placeholder = "想轉一筆給誰呢?"
		searchBar.backgroundColor = .clear
		searchBar.backgroundImage = UIImage()
		searchBar.delegate = self

		// 自訂搜尋欄外觀
		if let textField = searchBar.value(forKey: "searchField") as? UITextField {
			textField.backgroundColor = .systemGray6
			textField.layer.cornerRadius = 8
			textField.clipsToBounds = true
		}

		// 新增好友按鈕
		let addFriendButton = createToolbarButton(imageName: "icBtnAddFriends")

		// 建立水平堆疊視圖
		let stackView = UIStackView.create(
			arrangedSubviews: [searchBar, addFriendButton],
			axis: .horizontal,
			spacing: 8,
			alignment: .center,
			distribution: .fill
		)

		container.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.left.bottom.equalToSuperview().inset(8)
			make.right.equalToSuperview().inset(16)
		}

		searchBar.snp.makeConstraints { make in
			make.height.equalTo(36)
		}

		return container
	}()

	// 重新整理控制，下拉會根據目前選擇的後端，重新抓取一次朋友清單
	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refreshFriendsList), for: .valueChanged)
		return refreshControl
	}()

	// 朋友清單
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.reuseIdentifier)
		tableView.register(InvitationCell.self, forCellReuseIdentifier: InvitationCell.reuseIdentifier)
		tableView.addSubview(refreshControl)
		return tableView
	}()

	// 定義朋友清單的區段
	private enum Section {
		case invitations
		case main
	}

	// 定義 diffable data source 類型，支援顯示朋友的資料，包含是否優先顯示，個人圖像，名稱
	private typealias DataSource = UITableViewDiffableDataSource<Section, Friend>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>
	// 代表朋友清單的資料來源
	private var dataSource: DataSource!

	// MARK: - 幫助方法與元件

	private func createToolbarButton(imageName: String) -> UIButton {
		let button = UIButton(type: .custom)
		if let originalImage = UIImage(named: imageName) {
			let resizedImage = originalImage.withRenderingMode(.alwaysOriginal)
			button.setImage(resizedImage, for: .normal)
		}
		button.snp.makeConstraints { make in
			make.size.equalTo(CGSize(width: 24, height: 24))
		}
		return button
	}
}

// MARK: UISearchBarDelegate

extension FriendsViewController: UISearchBarDelegate {
	// 搜尋列的委派方法，用來根據姓名過濾朋友列表
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.filterFriends(with: searchText)
	}
}
