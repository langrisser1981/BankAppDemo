//
//  Friend.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/16.
//

import Foundation

// MARK: - FriendList

struct FriendList: Decodable {
    let friends: [Friend]
}

// MARK: - Friend

struct Friend: Decodable {
    let fid: String
    let name: String
    let status: Int
    let isTop: Bool?
    let updateDate: String?
}
