//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Mathielo on 29/06/24.
//

import SwiftUI

public extension Component.Text {
    struct Large: View {
        private let title: String
        
        public init(_ title: String) {
            self.title = title
        }
        
        public var body: some View {
            SwiftUI.Text(title)
                .font(.largeTitle)
        }
    }
}

#Preview {
    Component.Text.Large("Large Text!").preferredColorScheme(.light)
}

#Preview {
    Component.Text.Large("Large Text!").preferredColorScheme(.dark)
}
