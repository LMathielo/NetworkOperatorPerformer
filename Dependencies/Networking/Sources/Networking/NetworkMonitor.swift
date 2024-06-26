//
//  NetworkMonitor.swift
//  NetworkMonitor
//
//  Created by Lucas Mathielo on 26/06/24.
//

import Foundation
import Network

final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private var timeoutTime: TimeInterval = 0

    func setTimeout(with timeout: TimeInterval) {
        timeoutTime = timeout
    }
    
    var networkReachableStream: AsyncStream<Bool> {
        AsyncStream { [monitor] continuation in
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
