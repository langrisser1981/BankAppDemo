//
//  FriendCell.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/20.
//

import SnapKit
import UIKit

// MARK: - FriendCell

class FriendCell: UITableViewCell {
	static let reuseIdentifier = "FriendCell"

	// 定義 cell 中的 UI 元件
	private let starContainerView = UIView()
	private let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
	private let avatarImageView = UIImageView(image: UIImage(named: "imgFriendsFemaleDefault"))
	private let nameLabel = UILabel()
	private let transferButton = UIButton.createCustomButton(title: "轉帳", tag: 0)
	private let inviteButton = UIButton.createCustomButton(title: "邀請中", tag: 1)
	private let moreButton = UIButton.createCustomButton(title: "...", tag: 2)

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		// 設定星圖示
		starImageView.tintColor = .systemYellow

		// 將星圖示添加到容器視圖中
		starContainerView.addSubview(starImageView)

		// 設定頭像圖片
		avatarImageView.contentMode = .scaleAspectFill
		avatarImageView.clipsToBounds = true
		avatarImageView.layer.cornerRadius = 20

		// 設定名稱標籤
		nameLabel.font = .systemFont(ofSize: 16)

		// 設定轉帳按鈕
		transferButton.setTitleColor(.hotPink, for: .normal)
		transferButton.layer.borderColor = UIColor.hotPink.cgColor
		transferButton.layer.borderWidth = 1
		transferButton.layer.cornerRadius = 4
		transferButton.backgroundColor = .white // 設定背景為白色

		// 設定邀請中按鈕
		inviteButton.setTitleColor(.systemGray, for: .normal) // 淺灰色文字
		inviteButton.backgroundColor = .white // 白色背景
		inviteButton.layer.borderColor = UIColor.systemGray.cgColor // 淺灰色外框
		inviteButton.layer.borderWidth = 1
		inviteButton.layer.cornerRadius = 4

		// 設定更多選項按鈕
		moreButton.setTitleColor(.gray, for: .normal)
		moreButton.layer.cornerRadius = 4
		moreButton.backgroundColor = .white // 設定背景為白色

		// 建立水平堆疊視圖來排列所有元件
		let stackView = UIStackView.create(
			arrangedSubviews: [starContainerView, avatarImageView, nameLabel, transferButton, inviteButton, moreButton],
			axis: .horizontal,
			spacing: 8,
			alignment: .center,
			distribution: .fill
		)

		contentView.addSubview(stackView)

		// 設定約束
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
		}

		// 設定星圖示容器的約束
		starContainerView.snp.makeConstraints { make in
			make.width.equalTo(20)
			make.height.equalTo(stackView)
		}
		// 設定星圖示在容器中的約束
		starImageView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.size.equalTo(20)
		}
		avatarImageView.snp.makeConstraints { make in
			make.size.equalTo(40)
		}
		transferButton.snp.makeConstraints { make in
			make.width.equalTo(60)
		}
		inviteButton.snp.makeConstraints { make in
			make.width.equalTo(60)
		}
		moreButton.snp.makeConstraints { make in
			make.width.equalTo(30)
		}
	}

	// 根據朋友資料配置 cell
	func configure(with friend: Friend) {
		starImageView.isHidden = !friend.isTop
		nameLabel.text = friend.name
		inviteButton.isHidden = friend.status != 2
		moreButton.isHidden = friend.status == 2
	}
}
