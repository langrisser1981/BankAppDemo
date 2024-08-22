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
	// MARK: - 屬性

	weak var delegate: FriendsViewControllerDelegate?
	private let viewModel: FriendsViewModel
	private var cancellables = Set<AnyCancellable>()
	private var tapGesture: UITapGestureRecognizer!
	private var isSearchBarFocused = false
	private var keyboardFrame: CGRect?

	// MARK: - UI 元件

	// 定義顯示規則的列舉
	private enum DisplayState {
		case noFriends // 沒有好友
		case friendsWithoutInvitations // 有好友但沒有邀請
		case friendsWithInvitations // 有好友且有邀請
	}

	private var allViews: [UIView] = []
	private lazy var toolbar = createToolbar()
	private lazy var userInfo = createUserInfo()
	private lazy var emptyStateView = createEmptyStateView()
	private lazy var pageTabBar = createPageTabBar()
	private lazy var searchBar = createSearchBar()
	private lazy var invitationsTableView = createInvitationsTableView()
	private lazy var friendsTableView = createFriendsTableView()
	private lazy var refreshControl = createRefreshControl()

	// MARK: - 資料來源

	private enum Section { case main } // 定義好友清單的區段
	private typealias FriendsDataSource = UITableViewDiffableDataSource<Section, Friend>
	private typealias InvitationsDataSource = UITableViewDiffableDataSource<Section, Friend>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Friend>
	private var friendsDataSource: FriendsDataSource!
	private var invitationsDataSource: InvitationsDataSource!

	// MARK: - 初始化

	init(viewModel: FriendsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - 生命週期方法

	// 設定基本 UI 元件
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindViewModel()
		configureDataSource()
		setupTapGesture()
		setupKeyboardObservers()
	}

	// MARK: - 公開方法

	// 更新畫面顯示狀態
	func updateDisplay() {
		let state: DisplayState

		if viewModel.combinedFriends.isEmpty {
			state = .noFriends
		} else if viewModel.receivedInvitations.isEmpty {
			state = .friendsWithoutInvitations
		} else {
			state = .friendsWithInvitations
		}

		updateViews(for: state)
	}

	// MARK: - 私有方法

	// MARK: - 設定 UI

	// 設定基本 UI 元件
	private func setupUI() {
		view.backgroundColor = .systemBackground
		allViews = [toolbar, userInfo, invitationsTableView, pageTabBar, emptyStateView, searchBar, friendsTableView]

		emptyStateView.isHidden = true
		invitationsTableView.isHidden = true
		searchBar.isHidden = true
		friendsTableView.isHidden = true

		let mainStack = UIStackView.create(arrangedSubviews: allViews, axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
		view.addSubview(mainStack)
		mainStack.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
			make.left.right.bottom.equalToSuperview()
		}
	}

	// MARK: - 資料綁定

	// 綁定 ViewModel 資料到 UI
	private func bindViewModel() {
		// 綁定使用者資料
		viewModel.$user
			.receive(on: DispatchQueue.main)
			.sink { [weak self] user in
				if user != nil {
					self?.updateUserInfo()
				}
			}
			.store(in: &cancellables)

		// 監聽 combinedFriends 的變化，更新畫面顯示狀態
		viewModel.$combinedFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.updateDisplay()
			}
			.store(in: &cancellables)

		// 綁定收到的邀請清單
		viewModel.$receivedInvitations
			.receive(on: DispatchQueue.main)
			.sink { [weak self] invitations in
				self?.applySnapshot(with: invitations, to: self?.invitationsDataSource)
				self?.updateInvitationsTableViewHeight()
				self?.updateDisplay()
			}
			.store(in: &cancellables)

		// 綁定好友清單
		viewModel.$filteredFriends
			.receive(on: DispatchQueue.main)
			.sink { [weak self] friends in
				self?.applySnapshot(with: friends, to: self?.friendsDataSource)
				// 更新"好友"標籤的泡泡數字，只顯示 status == 2 的數量
				let count = friends.filter { $0.status == 2 }.count
				self?.updateFriendsBubble(count: count)
				// 順便將"聊天"標籤的泡泡數字更新為 99+
				self?.updateChatBubble(count: 100)
			}
			.store(in: &cancellables)
	}

	// 設定 diffable data source
	private func configureDataSource() {
		// 設定邀請清單的資料來源
		invitationsDataSource = InvitationsDataSource(tableView: invitationsTableView) { tableView, indexPath, friend in
			guard let cell = tableView.dequeueReusableCell(withIdentifier: InvitationCell.reuseIdentifier, for: indexPath) as? InvitationCell else {
				fatalError("無法取得 InvitationCell")
			}
			cell.configure(with: friend)
			return cell
		}

		// 設定好友清單的資料來源
		friendsDataSource = FriendsDataSource(tableView: friendsTableView) { tableView, indexPath, friend in
			guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseIdentifier, for: indexPath) as? FriendCell else {
				fatalError("無法取得 FriendCell")
			}
			cell.configure(with: friend)
			return cell
		}
	}

	// 套用新的快照到資料來源
	private func applySnapshot(with friends: [Friend], to dataSource: UITableViewDiffableDataSource<Section, Friend>?) {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(friends, toSection: .main)
		dataSource?.apply(snapshot, animatingDifferences: true) {
			self.refreshControl.endRefreshing()
		}
	}

	// MARK: - 更新 UI

	// 根據顯示狀態切換顯示
	private func updateViews(for state: DisplayState) {
		let visibleViews: [UIView]

		switch state {
		case .noFriends:
			visibleViews = [toolbar, userInfo, pageTabBar, emptyStateView]
		case .friendsWithoutInvitations:
			visibleViews = [toolbar, userInfo, pageTabBar, searchBar, friendsTableView]
		case .friendsWithInvitations:
			visibleViews = [toolbar, userInfo, invitationsTableView, pageTabBar, searchBar, friendsTableView]
		}

		// UIView.animate(withDuration: 0.3) {
		UIView.animate(withDuration: 0) {
			for view in self.allViews {
				view.isHidden = !visibleViews.contains(view)
			}
		}

		print("更新視圖顯示狀態: \(state)")
	}

	// 更新使用者資料 UI
	private func updateUserInfo() {
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

	// 更新邀請清單的高度
	private func updateInvitationsTableViewHeight() {
		invitationsTableView.layoutIfNeeded()
		let height = invitationsTableView.contentSize.height
		invitationsTableView.snp.updateConstraints { make in
			make.height.equalTo(height)
		}
	}

	// 將搜尋列移動到頂部
	private func moveSearchBarToTop() {
		guard isSearchBarFocused else { return }

		let offsetY = searchBar.convert(CGPoint.zero, to: nil).y - view.safeAreaInsets.top

		UIView.animate(withDuration: 0.3) {
			self.view.frame.origin.y = -offsetY
		}
	}

	// 恢復搜尋列位置
	private func restoreSearchBarPosition() {
		guard !isSearchBarFocused else { return }

		UIView.animate(withDuration: 0.3) {
			self.view.frame.origin.y = 0
		}
	}

	// MARK: - 事件處理

	// 處理登出按鈕點擊
	@objc private func logoutButtonTapped() {
		delegate?.didRequestLogout(self)
	}

	// 處理刷新好友列表
	@objc private func refreshFriendsList() {
		delegate?.didRequestRefresh(self)
	}

	// 處理點擊手勢
	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		let location = gesture.location(in: view)

		// 檢查觸碰位置是否在鍵盤區域外
		if let keyboardFrame = keyboardFrame,
		   !keyboardFrame.contains(location)
		{
			view.endEditing(true) // 收回鍵盤
		}
	}

	// 處理鍵盤顯示事件
	@objc private func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			self.keyboardFrame = keyboardFrame.cgRectValue
			tapGesture.isEnabled = true
		}
	}

	// 處理鍵盤隱藏事件
	@objc private func keyboardWillHide(notification: NSNotification) {
		keyboardFrame = nil
		tapGesture.isEnabled = false
	}
}

// MARK: - 建立 UI 元件擴展

private extension FriendsViewController {
	// 建立工具列
	func createToolbar() -> UIView {
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
	}

	// 建立使用者資訊視圖
	func createUserInfo() -> UIView {
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
	}

	// 建立空狀態視圖
	func createEmptyStateView() -> UIView {
		let container = UIView()
		container.backgroundColor = .systemBackground

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
			imageView, titleLabel, descriptionLabel, addFriendButton, helpLabel
		])
		stackView.axis = .vertical
		stackView.spacing = 16
		stackView.alignment = .center

		container.addSubview(stackView)

		stackView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.centerX.equalToSuperview()
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

		return container
	}

	// 建立頁面標籤列
	func createPageTabBar() -> UIView {
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

	// 建立搜尋列
	func createSearchBar() -> UIView {
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
	}

	// 建立邀請列表視圖
	func createInvitationsTableView() -> UITableView {
		let tableView = UITableView()
		tableView.register(InvitationCell.self, forCellReuseIdentifier: InvitationCell.reuseIdentifier)
		tableView.isScrollEnabled = false // 禁用滾動
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80 // 設置一個估計高度
		tableView.separatorStyle = .none // 移除分隔線
		return tableView
	}

	// 建立好友列表視圖
	func createFriendsTableView() -> UITableView {
		let tableView = UITableView()
		tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.reuseIdentifier)
		tableView.addSubview(refreshControl)
		return tableView
	}

	// 建立刷新控制元件
	func createRefreshControl() -> UIRefreshControl {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refreshFriendsList), for: .valueChanged)
		return refreshControl
	}

	// 建立工具列按鈕
	func createToolbarButton(imageName: String) -> UIButton {
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

// MARK: - 輔助方法擴展

private extension FriendsViewController {
	// 設定點擊手勢
	func setupTapGesture() {
		tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		tapGesture.cancelsTouchesInView = false // 確保其他觸碰事件(像是手指按按鈕)仍然能夠正常工作
		view.addGestureRecognizer(tapGesture)
		tapGesture.isEnabled = false // 一開始不用偵測手勢，要等到鍵盤顯示才開始偵測
	}

	// 設定鍵盤觀察者
	func setupKeyboardObservers() {
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
