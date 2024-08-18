//
//  User.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Foundation

// MARK: - UserResponse

struct UserResponse: Decodable {
	let user: User

	enum CodingKeys: String, CodingKey {
		case user = "response"
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		// 解碼 response 欄位為 User 陣列
		let userArray = try container.decode([User].self, forKey: .user)
		// 取得陣列中的第一個使用者，如果陣列為空則拋出錯誤
		guard let firstUser = userArray.first else {
			throw DecodingError.dataCorruptedError(forKey: .user, in: container, debugDescription: "使用者陣列為空")
		}
		user = firstUser
	}
}

// MARK: - User

struct User: Decodable {
	let name: String
	let kokoid: String
}
