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
		static var bubbleLabelKey = "bubbleLabelKey"
	}
    
	// 泡泡標籤的私有屬性
	private var bubbleLabel: UILabel? {
		get {
			objc_getAssociatedObject(self, &AssociatedKeys.bubbleLabelKey) as? UILabel
		}
		set {
			objc_setAssociatedObject(self, &AssociatedKeys.bubbleLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
    
	/// 建立一個帶有泡泡數字的標籤
	/// - Parameters:
	///   - text: 主標籤的文字
	///   - bubbleNumber: 泡泡中顯示的數字
	/// - Returns: 配置好的 UILabel
	static func createWithBubble(text: String, bubbleNumber: Int) -> UILabel {
		let label = UILabel()
		label.text = text
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 16)
        
		let bubbleLabel = UILabel()
		bubbleLabel.textAlignment = .center
		bubbleLabel.font = UIFont.systemFont(ofSize: 12)
		bubbleLabel.backgroundColor = .red
		bubbleLabel.textColor = .white
		bubbleLabel.layer.cornerRadius = 10
		bubbleLabel.layer.masksToBounds = true
		bubbleLabel.isHidden = bubbleNumber == 0
        
		label.addSubview(bubbleLabel)
		label.bubbleLabel = bubbleLabel
		label.setBubbleNumber(bubbleNumber)
        
		bubbleLabel.snp.makeConstraints { make in
			make.top.equalTo(label.snp.top).offset(-10)
			make.right.equalTo(label.snp.right).offset(10)
			make.height.equalTo(20)
			make.width.greaterThanOrEqualTo(20)
		}
        
		return label
	}
    
	/// 設定泡泡中顯示的數字
	/// - Parameter number: 要顯示的數字
	func setBubbleNumber(_ number: Int) {
		guard let bubbleLabel = bubbleLabel else { return }
        
		if number > 0 {
			bubbleLabel.text = number > 99 ? "99+" : "\(number)"
			bubbleLabel.isHidden = false
		} else {
			bubbleLabel.isHidden = true
		}
	}
}
