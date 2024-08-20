//
//  InvitationCell.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/20.
//

import SnapKit
import UIKit

// MARK: - InvitationCell

class InvitationCell: UITableViewCell {
	static let reuseIdentifier = "InvitationCell"

	// 定義 cell 中的 UI 元件
	private let avatarImageView = UIImageView(image: UIImage(named: "imgFriendsFemaleDefault"))
	private let nameLabel = UILabel()
	private let invitationLabel = UILabel()
	private let agreeButton = UIButton(type: .custom)
	private let deleteButton = UIButton(type: .custom)

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		// 設定頭像
		avatarImageView.contentMode = .scaleAspectFill
		avatarImageView.clipsToBounds = true
		avatarImageView.layer.cornerRadius = 20

		// 設定名稱標籤
		nameLabel.font = .systemFont(ofSize: 16, weight: .medium)

		// 設定邀請文字標籤
		invitationLabel.text = "邀請你成為好友"
		invitationLabel.font = .systemFont(ofSize: 14)
		invitationLabel.textColor = .gray

		// 設定同意按鈕
		agreeButton.setImage(UIImage(named: "btnFriendsAgree"), for: .normal)

		// 設定刪除按鈕
		deleteButton.setImage(UIImage(named: "btnFriendsDelet"), for: .normal)

		// 建立垂直堆疊視圖來放置名稱和邀請文字
		let labelStack = UIStackView.create(
			arrangedSubviews: [nameLabel, invitationLabel],
			axis: .vertical,
			spacing: 4,
			alignment: .leading,
			distribution: .fill
		)

		// 建立水平堆疊視圖來放置所有元素
		let mainStack = UIStackView.create(
			arrangedSubviews: [avatarImageView, labelStack, agreeButton, deleteButton],
			axis: .horizontal,
			spacing: 8,
			alignment: .center,
			distribution: .fill
		)

		contentView.addSubview(mainStack)

		// 設定約束
		mainStack.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
		}
		avatarImageView.snp.makeConstraints { make in
			make.size.equalTo(CGSize(width: 40, height: 40))
		}
		agreeButton.snp.makeConstraints { make in
			make.size.equalTo(CGSize(width: 24, height: 24))
		}
		deleteButton.snp.makeConstraints { make in
			make.size.equalTo(CGSize(width: 24, height: 24))
		}
	}

	func configure(with friend: Friend) {
		nameLabel.text = friend.name
	}
}
