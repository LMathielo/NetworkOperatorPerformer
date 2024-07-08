//
//  File.swift
//  
//
//  Created by Lucas Mathielo on 28/06/24.
//

import UIKit
import Networking

protocol ImageDownloaderService {
    func downloadImage(with url: String) async -> Result<UIImage, NetworkError>?
}

// Abstracting .init for UIImage as we dont want to expose what's being downloaded for NetworkLayer
extension UIImage: DownloadableContent { }

extension ImageDownloader {
    typealias Service = ImageDownloaderService
    
    class ServiceImpl: Service {
        private let networkPerformer: NetworkOperationPerformer
        
        convenience init() {
            self.init(networkPerformer: NetworkOperationPerformerImpl())
        }
        
        init(networkPerformer: NetworkOperationPerformer) {
            self.networkPerformer = networkPerformer
        }
        
        func downloadImage(with url: String) async -> Result<UIImage, NetworkError>? {
            await networkPerformer.performNetworkOperation(within: 5) {
                return await self.download(with: url)
            }
        }
        
        private func download(with urlString: String) async -> Result<UIImage, NetworkError> {
            guard let url = URL(string: urlString) else {
                return .failure(NetworkError.invalidUrl)
            }
            
            guard let (data, _) = try? await URLSession.shared.data(from: url) else {
                return .failure(NetworkError.downloadFailed)
            }
            
            guard let content = UIImage(data: data) else {
                return .failure(.parsingFailure)
            }
            
            return .success(content)
        }
    }
}
