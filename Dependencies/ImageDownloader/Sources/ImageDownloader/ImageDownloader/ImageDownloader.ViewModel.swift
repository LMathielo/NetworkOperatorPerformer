//
//  ImageDownloadViewModel.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 27/06/24.
//

import Foundation
import Networking
import UIKit

extension ImageDownloader.View.ViewModel {
    enum DownloadStatus: Equatable {
        case initial
        case loading
        case delayed
        case completed(UIImage)
        case error(String)
    }
}

extension ImageDownloader.View {
    
    @Observable class ViewModel {
        private let imageDownloader: NetworkImageDownloader
        private(set) var downloadStatus: DownloadStatus
        
        var shouldPresentSheet: Bool = false
        
        convenience init() {
            self.init(
                imageDownloader: NetworkImageDownloaderImpl(timeoutTime: 999)
            )
        }
        
        init(
            imageDownloader: NetworkImageDownloader
        ) {
            self.imageDownloader = imageDownloader
            self.downloadStatus = .initial
        }
        
        func setInitialState() {
            downloadStatus = .initial
        }
        
        func startDownloadingImage() async {
            downloadStatus = .loading
            
            //enhance this!
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
                if self?.downloadStatus == .loading {
                    self?.downloadStatus = .delayed
                }
            })
            
            // Create a service layer!! to help mocking network for tests + running isolated module
            let result = await imageDownloader.image(for: "https://picsum.photos/200/300")
            // let result = await imageDownloader.image(for: "https://hws.dev/paul.jpg")
            
            
            switch result {
            case .success(let image):
                downloadStatus = .completed(image)
                
            case .failure(let error):
                downloadStatus = .error(error.description)
            }
            
            shouldPresentSheet = true
        }
    }
    
}
