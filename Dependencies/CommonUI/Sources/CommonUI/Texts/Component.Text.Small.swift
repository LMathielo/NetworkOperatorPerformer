//
//  Text.swift
//
//
//  Created by Lucas Mathielo on 27/06/24.
//

import SwiftUI

public extension Component.Text {
    struct Small: View {
        private let title: String
        
        public init(_ title: String) {
            self.title = title
        }
        
        public var body: some View {
            SwiftUI.Text(title)
        }
    }
}

#Preview {
    Component.Text.Small("Small Text!").preferredColorScheme(.light)
}

#Preview {
    Component.Text.Small("Small Text!").preferredColorScheme(.dark)
}
