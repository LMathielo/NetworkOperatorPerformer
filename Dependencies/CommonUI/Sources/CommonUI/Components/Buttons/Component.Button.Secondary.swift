//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Mathielo on 29/06/24.
//

import SwiftUI

extension Component.Button.Secondary {
    public enum Style {
        case `default`
        case cancel
    }
}

extension Component.Button {
    
    public struct Secondary: View {
        @Environment(\.colorScheme) private var colorScheme
        private var scheme: Tokens.Button.Secondary {
            colorScheme == .light ? .light : .dark
        }
        
        private let label: String
        private let action: () -> Void
        private let style: Style
        
        private var customTextColor: Color? {
            style == .cancel ? Tokens.Color.red.rawValue : nil
        }
        
        public init(
            _ label: String,
            style: Style = .default,
            action: @escaping () -> Void
        ) {
            self.label = label
            self.style = style
            self.action = action
        }
        
        public var body: some View {
            SwiftUI.Button {
                action()
            } label: {
                Component.Text.Medium(
                    label,
                    customColor: customTextColor
                )
            }
        }
    }
    
}

#Preview {
    Component.Button.Secondary("Click me!") { }
        .preferredColorScheme(.light)
}

#Preview {
    Component.Button.Secondary("Click me!") { }
        .preferredColorScheme(.dark)
}

#Preview {
    Component.Button.Secondary("Click me!", style: .cancel) { }
        .preferredColorScheme(.light)
}
