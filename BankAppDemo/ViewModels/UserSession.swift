//
//  UserSession.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/19.
//

import Combine
import Foundation

class UserSession {
	@Published var userData: User?

	static let shared = UserSession()

	private init() {}

	func saveUserData(_ data: User) {
		userData = data
	}

	func clearUserData() {
		userData = nil
	}
}
