//
//  APIService.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation

class APIService {
	// Singleton instance
	static let shared = APIService()

	private init() {}

	// Enum to manage API URLs
	enum APIEndpoint: String {
		case user = "https://dimanyen.github.io/man.json"
		case friend1 = "https://dimanyen.github.io/friend1.json"
		case friend2 = "https://dimanyen.github.io/friend2.json"
		case friendWithInvites = "https://dimanyen.github.io/friend3.json"
		case noFriends = "https://dimanyen.github.io/friend4.json"
	}
}
