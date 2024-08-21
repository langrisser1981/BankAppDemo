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

	private var tapGesture: UITapGestureRecognizer!
	private var isSearchBarFocused = false
	private var keyboardFrame: CGRect?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		configureDataSource()
		bindViewModel()
		setupTapGesture()
		setupKeyboardObservers()
	}

	// MARK: - 排版

	// 設定畫面元件與排版
	private func setupUI() {
		view.backgroundColor = .systemBackground

		let mainStack = UIStackView.create(
			arrangedSubviews: [toolbar, userInfo, contentContainer],
			axis: .vertical,
			spacing: 0,
			alignment: .fill,
			distribution: .fill
		)

		view.addSubview(mainStack)
		mainStack.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.left.right.bottom.equalToSuperview()
		}
	}

	// MARK: - 資料綁定

	// 設定 diffable data source
	private func configureDataSource() {
		invitationsDataSource = InvitationsDataSource(tableView: invitationsTableView) { tableView, indexPath, friend in
			guard let cell = tableView.dequeueReusableCell(withIdentifier: InvitationCell.reuseIdentifier, for: indexPath) as? InvitationCell else {
				fatalError("無法取得 InvitationCell")
			}
			cell.configure(with: friend)
			return cell
		}

		friendsDataSource = FriendsDataSource(tableView: friendsTableView) { tableView, indexPath, friend in
			guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseIdentifier, for: indexPath) as? FriendCell else {
				fatalError("無法取得 FriendCell")
			}
			cell.configure(with: friend)
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

		// 監聽 combinedFriends 的變化，更新畫面顯示狀態
		viewModel.$combinedFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] friends in
				self?.updateContentVisibility(isEmpty: friends.isEmpty)
			}
			.store(in: &cancellables)

		// 收到的邀請清單
		viewModel.$receivedInvitations
			.receive(on: DispatchQueue.main)
			.sink { [weak self] invitations in
				self?.applySnapshot(with: invitations, to: self?.invitationsDataSource)
				self?.invitationsTableView.isHidden = invitations.isEmpty
				self?.updateInvitationsTableViewHeight()
			}
			.store(in: &cancellables)

		// 朋友清單
		viewModel.$filteredFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] friends in
				self?.applySnapshot(with: friends, to: self?.friendsDataSource)
				// 更新"好友"標籤的泡泡數字，只顯示status == 2的數量
				let count = friends.filter { $0.status == 2 }.count
				self?.updateFriendsBubble(count: count)
				// 順便將"聊天"標籤的泡泡數字更新為99+
				self?.updateChatBubble(count: 100)
			}
			.store(in: &cancellables)
	}

	// MARK: - 內部行為，如更新各種介面

	// 當朋友清單資料更新時，套用新的快照到資料來源
	private func applySnapshot(with friends: [Friend], to dataSource: UITableViewDiffableDataSource<Section, Friend>?) {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(friends, toSection: .main)
		dataSource?.apply(snapshot, animatingDifferences: true) {
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
		emptyStateView.isHidden = !isEmpty
		friendsContent.isHidden = isEmpty
		pageTabBar.isHidden = false

		// 根據是否有朋友來控制特定元素的顯示
		invitationsTableView.isHidden = isEmpty || viewModel.receivedInvitations.isEmpty
		searchBar.isHidden = isEmpty
		friendsTableView.isHidden = isEmpty
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

	// 更新 invitationsTableView 的高度
	private func updateInvitationsTableViewHeight() {
		invitationsTableView.layoutIfNeeded()
		let height = invitationsTableView.contentSize.height
		invitationsTableView.snp.updateConstraints { make in
			make.height.equalTo(height)
		}
	}

	private func moveSearchBarToTop() {
		guard isSearchBarFocused else { return }

		let offsetY = searchBar.convert(CGPoint.zero, to: nil).y - view.safeAreaInsets.top

		UIView.animate(withDuration: 0.3) {
			self.view.frame.origin.y = -offsetY
		}
	}

	private func restoreSearchBarPosition() {
		guard !isSearchBarFocused else { return }

		UIView.animate(withDuration: 0.3) {
			self.view.frame.origin.y = 0
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

	// 處理觸碰事件
	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		let location = gesture.location(in: view)

		// 檢查觸碰位置是否在鍵盤區域外
		if let keyboardFrame = keyboardFrame,
		   !keyboardFrame.contains(location)
		{
			view.endEditing(true) // 收回鍵盤
		}
	}

	// 鍵盤升起的時候要讓畫面向上移動，讓搜尋列貼齊螢幕上緣，確保內容不會被鍵盤遮住
	@objc private func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			self.keyboardFrame = keyboardFrame.cgRectValue
			tapGesture.isEnabled = true
		}
	}

	// 鍵盤收回的時候要讓元件回復到原本的高度位置
	@objc private func keyboardWillHide(notification: NSNotification) {
		keyboardFrame = nil
		tapGesture.isEnabled = false
	}

	// MARK: - 建立控制元件的宣告

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

		container.addSubview(emptyStateView)
		container.addSubview(friendsContent)

		emptyStateView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		friendsContent.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		return container
	}()

	// 空狀態視圖
	private lazy var emptyStateView: UIView = {
		let view = UIView()

		let emptyPageTabBar = createPageTabBar()
		let imageView = UIImageView(image: UIImage(named: "imgFriendsEmpty"))
		imageView.contentMode = .scaleAspectFit

		let titleLabel = UILabel()
		titleLabel.text = "就從加好友開始吧：）"
		titleLabel.font = .systemFont(ofSize: 28, weight: .medium)
		titleLabel.textAlignment = .center

		let descriptionLabel = UILabel()
		descriptionLabel.text = "與好友們一起用 KOKO 聊起來！\n還能互相收付款、發紅包喔：）"
		descriptionLabel.font = .systemFont(ofSize: 14)
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 0
		descriptionLabel.textColor = .lightGray

		let addFriendButton = GradientButton(type: .system)
		addFriendButton.setTitle("加好友", for: .normal)
		addFriendButton.setTitleColor(.white, for: .normal)
		addFriendButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		addFriendButton.layer.cornerRadius = 20
		addFriendButton.clipsToBounds = true

		let addFriendIcon = UIImageView(image: UIImage(named: "icAddFriendWhite"))
		addFriendButton.addSubview(addFriendIcon)
		addFriendIcon.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().inset(16)
			make.width.height.equalTo(24)
		}

		let helpLabel = UILabel()
		let fullText = "幫助好友更快找到你？設定 KOKO ID"
		let attributedString = NSMutableAttributedString(string: fullText)
		let range = (fullText as NSString).range(of: "設定 KOKO ID")
		attributedString.addAttribute(.foregroundColor, value: UIColor.hotPink, range: range)
		attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
		helpLabel.attributedText = attributedString
		helpLabel.font = .systemFont(ofSize: 13)
		helpLabel.textAlignment = .center

		let stackView = UIStackView(arrangedSubviews: [
			emptyPageTabBar, imageView, titleLabel, descriptionLabel, addFriendButton, helpLabel
		])
		stackView.axis = .vertical
		stackView.spacing = 16
		stackView.alignment = .center
		view.addSubview(stackView)

		stackView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}

		emptyPageTabBar.snp.makeConstraints { make in
			make.width.equalToSuperview()
		}

		imageView.snp.makeConstraints { make in
			make.width.equalTo(245)
			make.height.equalTo(172)
		}

		titleLabel.snp.makeConstraints { make in
			make.height.equalTo(29)
		}

		addFriendButton.snp.makeConstraints { make in
			make.width.equalTo(200)
			make.height.equalTo(40)
		}

		return view
	}()

	// 朋友內容視圖，包含頁面標籤列、搜尋列和朋友清單
	private lazy var friendsContent: UIStackView = {
		let stackView = UIStackView.create(
			arrangedSubviews: [invitationsTableView, pageTabBar, searchBar, friendsTableView],
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
		createPageTabBar()
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

	// 邀請清單
	private lazy var invitationsTableView: UITableView = {
		let tableView = UITableView()
		tableView.register(InvitationCell.self, forCellReuseIdentifier: InvitationCell.reuseIdentifier)
		tableView.isScrollEnabled = false // 禁用滾動
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80 // 設置一個估計高度
		tableView.separatorStyle = .none // 移除分隔線
		return tableView
	}()

	// 朋友清單
	private lazy var friendsTableView: UITableView = {
		let tableView = UITableView()
		tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.reuseIdentifier)
		tableView.addSubview(refreshControl)
		return tableView
	}()

	// 定義朋友清單的區段
	private enum Section {
		case main
	}

	// 定義 diffable data source 類型，支援顯示朋友的資料，包含是否優先顯示，個人圖像，名稱
	private typealias FriendsDataSource = UITableViewDiffableDataSource<Section, Friend>
	private typealias InvitationsDataSource = UITableViewDiffableDataSource<Section, Friend>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>
	// 代表朋友清單的資料來源
	private var friendsDataSource: FriendsDataSource!
	private var invitationsDataSource: InvitationsDataSource!

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

	// 建立頁面標籤列的方法
	private func createPageTabBar() -> UIView {
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

		// 新增底部的粉紅色線條
		let bottomLine = UIView()
		bottomLine.backgroundColor = .hotPink

		container.addSubview(stackView)
		container.addSubview(bottomLine)

		stackView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(8)
			make.left.equalToSuperview().inset(16)
		}

		bottomLine.snp.makeConstraints { make in
			make.bottom.equalToSuperview()
			make.height.equalTo(2)
			make.width.equalTo(friendsLabel.snp.width)
			make.left.equalTo(friendsLabel)
		}

		return container
	}

	// 訂閱觸碰事件，當鍵盤升起時，只要點鍵盤之外的區域，鍵盤會自動收回
	private func setupTapGesture() {
		tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		tapGesture.cancelsTouchesInView = false // 確保其他觸碰事件(像是手指按按鈕)仍然能夠正常工作
		view.addGestureRecognizer(tapGesture)
		tapGesture.isEnabled = false // 一開始不用偵測手勢，要等到鍵盤升起才開始偵測
	}

	// 訂閱鍵盤事件，處理鍵盤升起與收回的行為
	private func setupKeyboardObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
}

// MARK: UISearchBarDelegate

extension FriendsViewController: UISearchBarDelegate {
	// 搜尋列的委派方法，用來根據姓名過濾朋友列表
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.filterFriends(with: searchText)
	}

	// 按下 return 鍵盤應該要收起
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder() // 收回鍵盤
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		isSearchBarFocused = true
		moveSearchBarToTop()
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		isSearchBarFocused = false
		restoreSearchBarPosition()
	}
}

// MARK: - GradientButton

// 漸層按鈕類別
class GradientButton: UIButton {
	override func layoutSubviews() {
		super.layoutSubviews()
		gradientLayer.frame = bounds
	}

	private lazy var gradientLayer: CAGradientLayer = {
		let l = CAGradientLayer()
		l.frame = self.bounds
		l.colors = [UIColor(red: 73 / 255, green: 190 / 255, blue: 43 / 255, alpha: 1).cgColor,
		            UIColor(red: 120 / 255, green: 220 / 255, blue: 57 / 255, alpha: 1).cgColor]
		l.startPoint = CGPoint(x: 0, y: 0.5)
		l.endPoint = CGPoint(x: 1, y: 0.5)
		layer.insertSublayer(l, at: 0)
		return l
	}()
}
