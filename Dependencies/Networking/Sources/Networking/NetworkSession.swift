//
//  NetworkSession.swift
//
//
//  Created by Lucas Mathielo on 30/06/24.
//

import Foundation

protocol NetworkSession {
    func fetchData(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    func fetchData(from url: URL) async throws -> (Data, URLResponse) {
        try await self.data(from: url)
    }
}
