//
//  Friend.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Foundation

// MARK: - FriendResponse

struct FriendResponse: Decodable {
	let friends: [Friend]

	// 自定義解碼邏輯
	enum CodingKeys: String, CodingKey {
		case friends = "response"
	}
}

// MARK: - Friend

struct Friend: Decodable, Hashable {
	let name: String
	let status: Int
	let isTop: Bool
	let fid: String
	let updateDate: Date
    
	enum CodingKeys: String, CodingKey {
		case name, status, isTop, fid, updateDate
	}
    
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .name)
		status = try container.decode(Int.self, forKey: .status)
        
		let isTopString = try container.decode(String.self, forKey: .isTop)
		isTop = (isTopString == "1")
        
		fid = try container.decode(String.self, forKey: .fid)
        
		let updateDateString = try container.decode(String.self, forKey: .updateDate)
		if let date = Friend.decodeDate(from: updateDateString) {
			updateDate = date
		} else {
			throw DecodingError.dataCorruptedError(forKey: .updateDate,
			                                       in: container,
			                                       debugDescription: "無法將 updateDate 轉換為日期：\(updateDateString)")
		}
	}
    
	private static func decodeDate(from string: String) -> Date? {
		let formatters = [
			DateFormatter.yyyyMMdd,
			DateFormatter.yyyyMMddWithSlash
		]
        
		for formatter in formatters {
			formatter.timeZone = TimeZone(secondsFromGMT: 0) // 設置為 UTC
			if let date = formatter.date(from: string) {
				return date
			}
		}
        
		return nil
	}
    
	// MARK: - Hashable

	// 實現 Hashable 協議的 hash(into:) 方法
	func hash(into hasher: inout Hasher) {
		// 使用 fid 作為唯一標識符來計算哈希值
		hasher.combine(fid)
	}
    
	// 實現 Equatable 協議的 == 方法（Hashable 繼承自 Equatable）
	static func == (lhs: Friend, rhs: Friend) -> Bool {
		// 比較兩個 Friend 實例是否相等，這裡我們只比較 fid
		lhs.fid == rhs.fid
	}
}

extension DateFormatter {
	static let yyyyMMdd: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMdd"
		return formatter
	}()
    
	static let yyyyMMddWithSlash: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy/MM/dd"
		return formatter
	}()
}
