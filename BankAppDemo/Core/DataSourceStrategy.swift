//
//  DataSourceStrategy.swift
//  BankAppDemo
//
//  Created by 程信傑 on 2024/8/17.
//

import Combine
import Foundation

// MARK: - DataSourceStrategy

protocol DataSourceStrategy {
	func fetchData<T: Decodable>() async throws -> T
}

extension DataSourceStrategy {
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

class APIDataSource: DataSourceStrategy {
	private let endpoint: APIService.APIEndpoint

	init(endpoint: APIService.APIEndpoint) {
		self.endpoint = endpoint
	}

	func fetchData<T: Decodable>() async throws -> T {
		guard let url = URL(string: endpoint.rawValue) else {
			throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
		}

		let (data, _) = try await URLSession.shared.data(from: url)
		return try JSONDecoder().decode(T.self, from: data)
	}
}

// MARK: - LocalDataSource

class LocalDataSource: DataSourceStrategy {
	private let localFileName: String

	init(localFileName: String) {
		self.localFileName = localFileName
	}

	func fetchData<T: Decodable>() async throws -> T {
		guard let path = Bundle.main.path(forResource: localFileName, ofType: "json") else {
			throw NSError(domain: "File not found", code: 404, userInfo: nil)
		}

		let data = try Data(contentsOf: URL(fileURLWithPath: path))
		return try JSONDecoder().decode(T.self, from: data)
	}
}
