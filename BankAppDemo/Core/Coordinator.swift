//
//  Coordinator.swift
//
//  Created by 程信傑 on 2023/2/18.
//

import Combine
import Foundation
import UIKit

// MARK: - Coordinator

class Coordinator: UIViewController {
	var cancellables = Set<AnyCancellable>()

	// 使用者需要複寫底下兩個函式，用來處理資料訂閱，與元件顯示
	func bindViewModel() {}
	func start() { fatalError("Children should implement `start`.") }

	// MARK: Lifecycle

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		unbindViewModel()
		print("\(className): 已被釋放")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		bindViewModel()
		start()
	}

	func add(childController: UIViewController) {
		addChild(childController)
		view.addSubview(childController.view)
		childController.didMove(toParent: self)
	}

	func remove(childController: UIViewController) {
		childController.willMove(toParent: nil)
		childController.view.removeFromSuperview()
		childController.removeFromParent()
	}

	override func removeFromParent() {
		super.removeFromParent()
		guard isViewLoaded else { return }
		print("\(className): 已從畫面被移除")
	}

	func unbindViewModel() {
		cancellables.removeAll()
	}
}

// MARK: - ClassNamePrintable

protocol ClassNamePrintable {
	var className: String { get }
}

extension ClassNamePrintable {
	var className: String {
		String(describing: type(of: self))
	}
}

// MARK: - UIViewController + ClassNamePrintable

extension UIViewController: ClassNamePrintable {}
