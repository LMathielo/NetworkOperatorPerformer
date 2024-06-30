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
    @MainActor
    class ViewModel: ObservableObject {
        private let networkService: ImageDownloader.Service
        private let taskManager: TaskManager
        
        @Published private(set) var downloadStatus: DownloadStatus
        @Published var shouldPresentSheet: Bool = false
        
        convenience init() {
            self.init(
                networkService: ImageDownloader.ServiceImpl(),
                taskManager: TaskManagerImpl()
            )
        }
        
        init(
            networkService: ImageDownloader.Service,
            taskManager: TaskManager
        ) {
            self.networkService = networkService
            self.taskManager = taskManager
            self.downloadStatus = .initial
        }
    }
    
}

// MARK: - View Comunication

extension ImageDownloader.View.ViewModel {
    func setInitialState() {
        downloadStatus = .initial
    }
    
    func startDownloadingImage() {
        try? taskManager.start(downloadImage)
    }
    
    func cancelDownloadTask() {
        taskManager.cancelCurrentTask()
        setInitialState()
    }
}

// MARK: - Private Methods

private extension ImageDownloader.View.ViewModel {
    func downloadImage() async {
        downloadStatus = .loading
        defineDelayedLoading()
        
        // TODO: Needs to be removed as it breaks the current Unit Tests.
        // TODO: Delay added to hold loading state for 5 seconds as described in the exercise
        try? await Task.sleep(for: .seconds(5))
        
        // https://hws.dev/paul.jpg
        guard let result = await networkService.downloadImage(with: "https://picsum.photos/200/300") else { return }
        
        switch result {
        case .success(let image):
            self.downloadStatus = .completed(image)
            
        case .failure(let error):
            self.downloadStatus = .error(error.description)
        }
        
        self.shouldPresentSheet = true
    }
    
    func defineDelayedLoading() {
        Task { [weak self] in
            try await Task.sleep(for: .seconds(2))
            if self?.downloadStatus == .loading {
                self?.downloadStatus = .delayed
            }
        }
    }
}
