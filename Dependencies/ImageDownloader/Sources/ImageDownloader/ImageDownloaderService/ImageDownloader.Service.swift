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

extension ImageDownloader {
    typealias Service = ImageDownloaderService
    
    class ServiceImpl: Service {
        private let networkPerformer = NetworkImageDownloaderImpl(timeoutTime: 10)
        
        func downloadImage(with url: String) async -> Result<UIImage, NetworkError>? {
            await networkPerformer.image(for: url)
        }
    }
}
