//
//  NetworkMonitor.swift
//  NetworkMonitor
//
//  Created by Lucas Mathielo on 26/06/24.
//

import Foundation
import Network

protocol NetworkMonitor {
    func setTimeout(with: TimeInterval)
    var networkReachableStream: AsyncStream<Bool> { get }
}

final class NetworkMonitorImpl: NetworkMonitor {
    private var timeoutTime: TimeInterval = 0

    func setTimeout(with timeout: TimeInterval) {
        timeoutTime = timeout
    }
    
    var networkReachableStream: AsyncStream<Bool> {
        AsyncStream { continuation in
            
            let monitor = NWPathMonitor()
            monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
            
            monitor.pathUpdateHandler = { _ in
                if monitor.currentPath.status == .satisfied {
                    print("SendingStream -> Network reachable: true")
                    continuation.yield(true)
                    continuation.finish()
                }
            }
            
            let workItem = DispatchWorkItem { continuation.finish() }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeoutTime, execute: workItem)
            
            continuation.onTermination = { @Sendable _ in
                print("termination CALLED!")
                continuation.yield(false)
                monitor.cancel()
            }
        }
    }
}
