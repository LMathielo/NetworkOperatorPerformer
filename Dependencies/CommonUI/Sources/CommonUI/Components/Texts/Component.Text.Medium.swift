//
//  Text.swift
//
//
//  Created by Lucas Mathielo on 27/06/24.
//

import SwiftUI

public extension Component.Text {
    
    struct Medium: View {
        @Environment(\.colorScheme) private var colorScheme
        private var scheme: Tokens.Text.Medium {
            colorScheme == .light ? .light : .dark
        }
        
        private let title: String
        private let customColor: Color?
        
        public init(_ title: String, customColor: Color? = nil) {
            self.title = title
            self.customColor = customColor
        }
        
        public var body: some View {
            SwiftUI.Text(title)
                .font(scheme.font)
                .ifForegroundStyle((customColor ?? scheme.tintColor))
        }
    }
}

#Preview {
    Component.Text.Medium("Medium Text!")
        .preferredColorScheme(.light)
}

#Preview {
    Component.Text.Medium("Medium Text!")
        .preferredColorScheme(.dark)
}
