//
//  UIButton+Extension.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/18.
//

import UIKit

extension UIButton {
	static func createCustomButton(title: String, tag: Int) -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(title, for: .normal)
		button.setTitleColor(.white, for: .normal) // 設定按鈕文字顏色為白色
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium) // 設定文字字體
		button.tag = tag
		button.backgroundColor = .systemBlue // 設定按鈕背景顏色
		button.layer.cornerRadius = 8 // 設定按鈕圓角
		return button
	}
}
