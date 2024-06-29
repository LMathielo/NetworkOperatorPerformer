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
            monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
            
            monitor.pathUpdateHandler = { @Sendable path in
                    print("SendingStream -> Network reachable: \(path.status)")
                    continuation.yield(path.status)
            }
            
            continuation.onTermination = { @Sendable _ in
                print("termination CALLED!")
                monitor.cancel()
            }
        }
    }
}
