//
//  MockCoordinator.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation
import SnapKit
import UIKit

// MARK: - MockCoordinator

class MockCoordinator: Coordinator {
	let screenTitle: String

	init(screenTitle: String) {
		self.screenTitle = screenTitle
		super.init()
	}

	override func start() {
		let viewController = MockViewController(title: screenTitle)
		add(childController: viewController)
	}
}

// MARK: - MockViewController

class MockViewController: UIViewController {
	private let titleLabel = UILabel()

	init(title: String) {
		super.init(nibName: nil, bundle: nil)
		self.title = title
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
	}

	private func setupUI() {
		titleLabel.text = title
		view.addSubview(titleLabel)

		titleLabel.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
}
