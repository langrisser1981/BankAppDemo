//
//  DataSourceStrategy.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Combine
import Foundation

// MARK: - DataSourceStrategy

// 定義資料來源策略的協定
protocol DataSourceStrategy {
	func fetchData<T: Decodable>() async throws -> T
}

extension DataSourceStrategy {
	// 提供一個將非同步方法轉換為 Combine Publisher 的擴展方法
	func fetchDataPublisher<T: Decodable>() -> AnyPublisher<T, Error> {
		Future { promise in
			Task {
				do {
					let data = try await self.fetchData() as T
					promise(.success(data))
				} catch {
					promise(.failure(error))
				}
			}
		}
		.eraseToAnyPublisher()
	}
}

// MARK: - APIDataSource

// 實作 API 資料來源策略
class APIDataSource: DataSourceStrategy {
	private let endpoint: APIService.APIEndpoint

	init(endpoint: APIService.APIEndpoint) {
		self.endpoint = endpoint
	}

	func fetchData<T: Decodable>() async throws -> T {
		// 檢查 URL 是否有效
		guard let url = URL(string: endpoint.rawValue) else {
			throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
		}

		// 使用 URLSession 取得資料
		let (data, _) = try await URLSession.shared.data(from: url)
		return try JSONDecoder().decode(T.self, from: data)
	}
}

// MARK: - LocalDataSource

// 實作本地資料來源策略
class LocalDataSource: DataSourceStrategy {
	private let localFileName: String

	init(localFileName: String) {
		self.localFileName = localFileName
	}

	func fetchData<T: Decodable>() async throws -> T {
		// 檢查本地檔案是否存在
		guard let path = Bundle.main.path(forResource: localFileName, ofType: "json") else {
			throw NSError(domain: "File not found", code: 404, userInfo: nil)
		}

		// 讀取本地檔案並解碼
		let data = try Data(contentsOf: URL(fileURLWithPath: path))
		return try JSONDecoder().decode(T.self, from: data)
	}
}
