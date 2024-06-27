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
    var networkReachableStream: AsyncThrowingStream<Bool, Error> { get }
}

final class NetworkMonitorImpl: NetworkMonitor {
    private var timeoutTime: TimeInterval = 0

    func setTimeout(with timeout: TimeInterval) {
        timeoutTime = timeout
    }
    
    var networkReachableStream: AsyncThrowingStream<Bool, Error> {
        AsyncThrowingStream { continuation in
            
            let monitor = NWPathMonitor()
            monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
            
            monitor.pathUpdateHandler = { @Sendable path in
                if path.status == .satisfied {
                    print("SendingStream -> Network reachable: true")
                    continuation.yield(true)
                    continuation.finish()
                }
            }
            
            let workItem = DispatchWorkItem { continuation.finish(throwing: NetworkError.timeout) }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeoutTime, execute: workItem)
            
            continuation.onTermination = { @Sendable _ in
                print("termination CALLED!")
                monitor.cancel()
            }
        }
    }
}
