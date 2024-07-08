//
//  NetworkMonitor.swift
//  NetworkMonitor
//
//  Created by Lucas Mathielo on 26/06/24.
//

import Foundation
import Network

protocol NetworkMonitor {
    func signalNetworkReachable() async
}

final class NetworkMonitorImpl: NetworkMonitor {
    func signalNetworkReachable() async {
        for await _ in self.networkReachableStream.filter({ $0 == .satisfied }) {
            return
        }
    }

    private var networkReachableStream: AsyncStream<NWPath.Status> {
        AsyncStream { continuation in
            let monitor = NWPathMonitor()
            
            monitor.pathUpdateHandler = { @Sendable path in
                    continuation.yield(path.status)
            }
            
            continuation.onTermination = { @Sendable _ in
                monitor.cancel()
            }
            
            monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
        }
    }
}
