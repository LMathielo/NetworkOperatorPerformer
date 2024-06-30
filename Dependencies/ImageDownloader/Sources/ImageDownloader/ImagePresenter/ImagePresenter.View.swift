//
//  ImageDownloadedView.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 27/06/24.
//

import SwiftUI
import CommonUI

enum ImagePresenter { }

extension ImagePresenter {
    
    struct View: SwiftUI.View {
        let image: UIImage?
        let error: String?

        var body: some SwiftUI.View {
            
            VStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                
                if let error {
                    Component.Text.Large("=(")
                        .padding()
                    Component.Text.Small(error)
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
    }
    
}

#Preview {
    ImagePresenter.View(image: nil, error: "Network Error")
}
