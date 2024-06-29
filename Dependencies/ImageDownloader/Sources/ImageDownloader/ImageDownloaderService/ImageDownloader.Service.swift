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
            return try? await networkPerformer.performNetworkOperation(for: url, within: 10)
        }
    }
}
