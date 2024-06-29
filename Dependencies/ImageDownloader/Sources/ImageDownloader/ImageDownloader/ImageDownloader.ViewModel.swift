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
//    @MainActor
    @Observable class ViewModel {
        private let networkService: ImageDownloader.Service
        
        private(set) var downloadStatus: DownloadStatus
        private var downloadTask: Task<(), Never>?
        
        var shouldPresentSheet: Bool = false
        
        convenience init() {
            self.init(
                networkService: ImageDownloader.ServiceImpl()
            )
        }
        
        init(
            networkService: ImageDownloader.Service
        ) {
            self.networkService = networkService
            self.downloadStatus = .initial
        }
        
        nonisolated func setInitialState() {
            downloadStatus = .initial
        }
        
        func startDownloadingImage() {
            downloadTask = Task {
                downloadStatus = .loading
                defineDelayedLoading()
                
//            https://hws.dev/paul.jpg
                
                guard let result = await networkService.downloadImage(with: "https://picsum.photos/200/300") else { return }
            
                switch result {
                case .success(let image):
                    downloadStatus = .completed(image)
                    
                case .failure(let error):
                    downloadStatus = .error(error.description)
                }
                
                shouldPresentSheet = true
            }
        }
        
        func cancelDownloadTask() {
            downloadTask?.cancel()
            downloadTask = nil
            downloadStatus = .initial
        }
        
        private func defineDelayedLoading() {
            Task {
                try await Task.sleep(for: .seconds(2))
                
//                await MainActor.run { [weak self] in
                    if self.downloadStatus == .loading {
                        self.downloadStatus = .delayed
                    }
//                }
            }
        }
    }
    
}
