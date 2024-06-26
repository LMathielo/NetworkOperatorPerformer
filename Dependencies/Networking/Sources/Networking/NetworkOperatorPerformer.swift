//
//  NetworkOperatorPerformer.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 26/06/24.
//

import Foundation

public protocol NetworkOperationPerformer {
    func performNetworkOperation(
        using closure: @escaping () -> Void,
        withinSeconds timeoutDuration: TimeInterval
    ) async
}

public actor NetworkOperationPerformerImpl: NetworkOperationPerformer {
    private let networkMonitor: NetworkMonitor
    
    public init () {
        self.networkMonitor = NetworkMonitorImpl()
    }
    
    init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
    }
    
    /// Attempts to perform a network operation using the given `closure`, within the given `timeoutDuration`.
    /// If the network is not accessible within the given `timeoutDuration`, the operation is not performed.
    public func performNetworkOperation(
        using closure: @escaping () -> Void,
        withinSeconds timeoutDuration: TimeInterval
    ) async {
        networkMonitor.setTimeout(with: timeoutDuration)
        
        for await networkAvailable in networkMonitor.networkReachableStream {
            if networkAvailable {
                closure()
            }
        }
        
        print("Stream finished.")
    }
}
