//
//  NetworkOperatorPerformer.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 26/06/24.
//

import Foundation

// Ideally, this should be a generic <T: Decodable> to handle proper API responses.
// Using `DownloadableContent` in this case as we want to abstract the usage of NetworkOperation to any Object that can be initialised with Data. E.g: UIImages
public protocol DownloadableContent {
    init?(data: Data)
}

public protocol NetworkOperationPerformer {
    /// Attempts to perform a network operation using the given `url` string, within the given `timeoutDuration`.
    /// If the network is not accessible within the given `timeoutDuration`, the operation is not performed.
    ///
    func performNetworkOperation<T: DownloadableContent>(
        for urlString: String,
        within timeoutDuration: TimeInterval
    ) async -> Result<T, NetworkError>?
}

public final class NetworkOperationPerformerImpl: NetworkOperationPerformer {
    private let networkMonitor: NetworkMonitor
    private let session: NetworkSession
    
    public convenience init () {
        self.init(
            networkMonitor: NetworkMonitorImpl(),
            session: URLSession.shared
        )
    }
    
    init(
        networkMonitor: NetworkMonitor,
        session: NetworkSession
    ) {
        self.networkMonitor = networkMonitor
        self.session = session
    }
    
    public func performNetworkOperation<T: DownloadableContent>(for urlString: String, within timeoutDuration: TimeInterval) async -> Result<T, NetworkError>? {
        
        return await withTaskGroup(of: Result<T, NetworkError>?.self) { group in
            group.addTask {
                return await self.performRequestIfNetworkReachable(for: urlString)
            }
            
            group.addTask {
                try? await Task.sleep(for: .seconds(timeoutDuration))
                if Task.isCancelled { return nil }
                return .failure(NetworkError.timeout)
            }
            
            guard let result = await group.next() else {
                return .failure(NetworkError.unknown("not possible"))
            }
            
            group.cancelAll()
            
            return result
        }
    }
}

private extension NetworkOperationPerformerImpl {
    func performRequestIfNetworkReachable<T: DownloadableContent>(for urlString: String) async -> Result<T, NetworkError>? {
        
        await self.networkMonitor.signalNetworkReachable()
        
        // explicitly returns the task, if its on a cancelled state to avoid unecessary API calls
        if Task.isCancelled { return nil }
        
        guard let url = URL(string: urlString) else {
            return .failure(NetworkError.invalidUrl)
        }
        
        guard let (data, _) = try? await session.fetchData(from: url) else {
            return .failure(NetworkError.downloadFailed)
        }
        
        guard let content = T(data: data) else {
            return .failure(.parsingFailure)
        }
        
        return .success(content)
    }
}
