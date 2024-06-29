//
//  ImageDownloadView.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 27/06/24.
//

import SwiftUI
import CommonUI

extension ImageDownloader {
    
    public struct View: SwiftUI.View {
        @State var viewModel = ViewModel()
        
        public init() { }
        
        public var body: some SwiftUI.View {
            VStack{
                switch viewModel.downloadStatus {
                case .initial:
                    Component.Button("Start Download") {
                        viewModel.startDownloadingImage()
                    }
                case .loading, .delayed:
                    Component.LoadingView(delayed: viewModel.downloadStatus == .delayed) {
                        viewModel.cancelDownloadTask()
                    }
                case .completed, .error:
                    EmptyView()
                }
            }
            .sheet(
                isPresented: $viewModel.shouldPresentSheet,
                onDismiss: {
                    viewModel.setInitialState()
                },
                content: {
                    if case let ViewModel.DownloadStatus.completed(image) = viewModel.downloadStatus {
                        ImagePresenter.View(image: image, error: nil)
                    }
                    
                    if case let ViewModel.DownloadStatus.error(error) = viewModel.downloadStatus {
                        ImagePresenter.View(image: nil, error: error)
                    }
                }
            )
        }
    }
    
}

#Preview {
    ImageDownloader.View()
}
