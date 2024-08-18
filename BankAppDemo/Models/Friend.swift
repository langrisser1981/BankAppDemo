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
        
		// 將 isTop 從字串轉換為布林值
		let isTopString = try container.decode(String.self, forKey: .isTop)
		isTop = (isTopString == "1")
        
		fid = try container.decode(String.self, forKey: .fid)
        
		// 解碼日期字串並轉換為 Date 物件
		let updateDateString = try container.decode(String.self, forKey: .updateDate)
		if let date = Friend.decodeDate(from: updateDateString) {
			updateDate = date
		} else {
			throw DecodingError.dataCorruptedError(forKey: .updateDate,
			                                       in: container,
			                                       debugDescription: "無法將 updateDate 轉換為日期：\(updateDateString)")
		}
	}
    
	// 嘗試使用多種日期格式解碼日期字串
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

	// 使用 fid 作為唯一標識符來計算哈希值
	func hash(into hasher: inout Hasher) {
		hasher.combine(fid)
	}
    
	// 比較兩個 Friend 實例是否相等，只比較 fid
	static func == (lhs: Friend, rhs: Friend) -> Bool {
		lhs.fid == rhs.fid
	}
    
	// 用於測試的便利初始化器
	init(name: String, status: Int, isTop: Bool, fid: String, updateDate: String) {
		self.name = name
		self.status = status
		self.isTop = isTop
		self.fid = fid
		self.updateDate = Friend.decodeDate(from: updateDate) ?? Date()
	}
}

// 擴展 DateFormatter 以提供常用的日期格式
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
