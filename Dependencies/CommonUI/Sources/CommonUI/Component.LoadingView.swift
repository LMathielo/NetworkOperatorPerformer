//
//  LoadingView.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 27/06/24.
//

import SwiftUI

extension Component {
    public struct LoadingView: View {
        private let delayed: Bool // @State breaks the component view from updating! Why?
        private var cancelAction: (() -> Void)?
        
        public init(delayed: Bool, cancelAction: (() -> Void)? = nil) {
            self.delayed = delayed
            self.cancelAction = cancelAction
        }
        
        public var body: some View {
            VStack {
                ProgressView {
                    if delayed {
                        Component.Text("This is taking longer than expected...")
                    }
                }
                .controlSize(.extraLarge)
                
                if delayed, let cancelAction {
                    Component.Button("Cancel") {
                        cancelAction()
                    }
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    Component.LoadingView(delayed: true) { }
        .preferredColorScheme(.light)
}

#Preview {
    Component.LoadingView(delayed: true) { }
        .preferredColorScheme(.dark)
}