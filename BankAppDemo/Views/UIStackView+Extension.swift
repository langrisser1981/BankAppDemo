//
//  UIStackView+Extension.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation
import UIKit

extension UIStackView {
	/// 創建一個配置好的 UIStackView
	/// - Parameters:
	///   - arrangedSubviews: 要添加到 stack view 的子視圖數組
	///   - axis: stack view 的軸向（默認為垂直）
	///   - spacing: 子視圖之間的間距（默認為 0）
	///   - alignment: stack view 的對齊方式（默認為 .fill）
	///   - distribution: stack view 的分佈方式（默認為 .fill）
	/// - Returns: 配置好的 UIStackView
	static func create(
		arrangedSubviews: [UIView],
		axis: NSLayoutConstraint.Axis = .vertical,
		spacing: CGFloat = 0,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill
	) -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
		stackView.axis = axis
		stackView.spacing = spacing
		stackView.alignment = alignment
		stackView.distribution = distribution
		return stackView
	}
}
