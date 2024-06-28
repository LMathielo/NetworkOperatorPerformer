//
//  ImageDownloadedView.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 27/06/24.
//

import SwiftUI

enum ImagePresenter { }

extension ImagePresenter {
    
    struct View: SwiftUI.View {
        let image: UIImage?
        let error: String?

        var body: some SwiftUI.View {
            
            if let image {
                Image(uiImage: image).padding()
            }
            
            if let error {
                Text(error)
            }
        }
    }
    
}

#Preview {
    ImagePresenter.View(image: nil, error: nil)
}
