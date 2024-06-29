//
//  NetworkOperatorPerformer.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 26/06/24.
//

import Foundation

protocol NetworkOperationPerformer {
    func performNetworkOperation<T>(
        within timeoutDuration: TimeInterval,
        using closure: @escaping () async throws -> T
    ) async throws -> T?
}

final actor NetworkOperationPerformerImpl: NetworkOperationPerformer {
    private let networkMonitor: NetworkMonitor
    
    init () {
        self.networkMonitor = NetworkMonitorImpl()
    }
    
    init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
    }
    
    /// Attempts to perform a network operation using the given `closure`, within the given `timeoutDuration`.
    /// If the network is not accessible within the given `timeoutDuration`, the operation is not performed.
    func performNetworkOperation<T>(
        within timeoutDuration: TimeInterval,
        using closure: @escaping () async throws -> T
    ) async throws -> T? {
        networkMonitor.setTimeout(with: timeoutDuration)
                
        for try await networkAvailable in networkMonitor.networkReachableStream {
            if networkAvailable, !Task.isCancelled {
                return try await closure()
            }
        }
        
        print("Stream finished.")
        return nil
    }
}
