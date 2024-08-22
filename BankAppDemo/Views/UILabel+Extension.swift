//
//  UILabel+Extension.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/19.
//

import SnapKit
import UIKit

extension UILabel {
	// 用於儲存泡泡標籤的關聯物件鍵值
	private enum AssociatedKeys {
		static let bubbleLabelKey = UnsafeRawPointer(bitPattern: "bubbleLabelKey".hashValue)!
	}

	// 泡泡標籤的私有屬性
	private var bubbleLabel: UILabel? {
		get {
			objc_getAssociatedObject(self, AssociatedKeys.bubbleLabelKey) as? UILabel
		}
		set {
			objc_setAssociatedObject(self, AssociatedKeys.bubbleLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	// 新增：定義泡泡標籤的最小尺寸
	private static let minBubbleSize: CGFloat = 20

	/// 建立一個帶有泡泡數字的標籤
	/// - Parameters:
	///   - text: 主標籤的文字
	///   - bubbleNumber: 泡泡中顯示的數字
	/// - Returns: 配置好的 UILabel
	static func createWithBubble(text: String, bubbleNumber: Int) -> UILabel {
		let label = UILabel()
		label.text = text
		label.textAlignment = .left // 將文字對齊改為左對齊
		label.font = UIFont.systemFont(ofSize: 16)

		let bubbleLabel = UILabel()
		bubbleLabel.textAlignment = .center
		bubbleLabel.font = UIFont.systemFont(ofSize: 12)
		// 修改背景顏色為淺粉紅色
		bubbleLabel.backgroundColor = .softPink
		bubbleLabel.textColor = .white
		bubbleLabel.layer.cornerRadius = minBubbleSize / 2 // 設置圓角為最小尺寸的一半
		bubbleLabel.layer.masksToBounds = true
		// 移除外框
		bubbleLabel.layer.borderWidth = 0
		bubbleLabel.isHidden = bubbleNumber == 0

		label.addSubview(bubbleLabel)
		label.bubbleLabel = bubbleLabel
		label.setBubbleNumber(bubbleNumber)

		// 設定泡泡標籤的約束
		bubbleLabel.snp.makeConstraints { make in
			make.top.equalTo(label.snp.top).offset(-10)
			make.left.equalTo(label.snp.right).offset(-2) // 新增：設置左邊界約束
			make.height.equalTo(minBubbleSize)
			make.width.greaterThanOrEqualTo(minBubbleSize)
		}

		// 設定文字內容的約束
		label.snp.makeConstraints { make in
			make.height.greaterThanOrEqualTo(20)
		}

		// 在佈局變更後更新泡泡位置
		label.setNeedsLayout()
		label.layoutIfNeeded()

		return label
	}

	/// 設定泡泡中顯示的數字
	/// - Parameter number: 要顯示的數字
	func setBubbleNumber(_ number: Int) {
		guard let bubbleLabel = bubbleLabel else { return }

		if number > 0 {
			bubbleLabel.text = number > 99 ? "99+" : "\(number)"
			bubbleLabel.isHidden = false

			// 計算所需的寬度
			let textWidth = bubbleLabel.intrinsicContentSize.width
			let requiredWidth = max(textWidth + 10, UILabel.minBubbleSize)

			// 更新泡泡標籤的寬度約束
			bubbleLabel.snp.updateConstraints { make in
				make.width.greaterThanOrEqualTo(requiredWidth) // 確保有足夠的寬度
			}
		} else {
			bubbleLabel.isHidden = true
		}

		// 強制更新佈局
		setNeedsLayout()
		layoutIfNeeded()
	}
}
