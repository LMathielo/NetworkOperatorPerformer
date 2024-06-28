//
//  NetworkImageDownloader.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 27/06/24.
//

import Foundation
import UIKit

public protocol NetworkImageDownloader {
    func image(for urlString: String) async -> Result<UIImage, NetworkError>
}

public actor NetworkImageDownloaderImpl: NetworkImageDownloader {
    private let networkOperationPerformer: NetworkOperationPerformer
    private let timeoutTime: TimeInterval
    private var image: UIImage?
    
    public init (timeoutTime: TimeInterval) {
        self.timeoutTime = timeoutTime
        self.networkOperationPerformer = NetworkOperationPerformerImpl()
    }
    
    init(
        timeoutTime: TimeInterval,
        networkOperationPerformer: NetworkOperationPerformer
    ) {
        self.timeoutTime = timeoutTime
        self.networkOperationPerformer = networkOperationPerformer
    }
    
    
    public func image(for urlString: String) async -> Result<UIImage, NetworkError> {
        do {
            try await networkOperationPerformer
                .performNetworkOperation(
                    using: { [weak self] in
                        print("closure started!")
                        try await self?.downloadImage(with: urlString)
                        print("closure finished!")
                    },
                    withinSeconds: timeoutTime
                )
            
            guard let image else {
                assertionFailure("Upon sucessful download, image can't be nil!")
                throw NetworkError.parsingFailure
            }
            
            return .success(image)
        }
        catch {
            return .failure(error as? NetworkError ?? NetworkError.unknown(error.localizedDescription))
        }
    }
    
    private func downloadImage(with urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidUrl
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw NetworkError.downloadFailed
        }
        
        self.image = image
    }
}
