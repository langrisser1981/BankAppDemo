//
//  LoginViewController.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Foundation
import UIKit

// MARK: - LoginViewControllerDelegate

protocol LoginViewControllerDelegate: AnyObject {
	func didSelectStatus(_ status: Int)
}

// MARK: - LoginViewController

class LoginViewController: UIViewController {
	weak var delegate: LoginViewControllerDelegate?
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
    
	private func setupUI() {
		// 創建三個按鈕
		let button1 = UIButton(type: .system)
		button1.setTitle("狀態 1", for: .normal)
		button1.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		button1.tag = 1
        
		let button2 = UIButton(type: .system)
		button2.setTitle("狀態 2", for: .normal)
		button2.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		button2.tag = 2
        
		let button3 = UIButton(type: .system)
		button3.setTitle("狀態 3", for: .normal)
		button3.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		button3.tag = 3
        
		// 設置按鈕的佈局
		// 創建一個垂直堆疊視圖
		let stackView = UIStackView(arrangedSubviews: [button1, button2, button3])
		stackView.axis = .vertical
		stackView.spacing = 20
		stackView.alignment = .center
		stackView.translatesAutoresizingMaskIntoConstraints = false

		// 將堆疊視圖添加到主視圖
		view.addSubview(stackView)
        
		// 設置堆疊視圖的約束
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			button1.widthAnchor.constraint(equalToConstant: 200),
			button2.widthAnchor.constraint(equalToConstant: 200),
			button3.widthAnchor.constraint(equalToConstant: 200)
		])
	}
    
	@objc private func buttonTapped(_ sender: UIButton) {
		delegate?.didSelectStatus(sender.tag)
	}
}
