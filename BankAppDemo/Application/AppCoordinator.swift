//
//  AppCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import UIKit

class AppCoordinator: Coordinator {
	override func start() {
		// 設置背景顏色為白色
		view.backgroundColor = .white

		// 創建label
		let label = UILabel()
		label.text = "開發中"
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 24)

		// 設置label的autoresizing屬性為false,以便使用Auto Layout
		label.translatesAutoresizingMaskIntoConstraints = false

		// 將label添加到view中
		view.addSubview(label)

		// 設置Auto Layout約束
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}
}
