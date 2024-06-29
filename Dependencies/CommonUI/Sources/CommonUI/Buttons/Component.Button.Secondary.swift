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
        
        func color(for scheme: ColorScheme) -> Color {
            switch self {
            case .default:
                return scheme == .light ? .black : .white
            case .cancel:
                return .red
            }
        }
    }
}

extension Component.Button {
    
    public struct Secondary: View {
        @Environment(\.colorScheme) private var colorScheme
        
        private let label: String
        private let action: () -> Void
        private let style: Style
        
        public init(
            _ label: String,
            style: Style,
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
                Component.Text.Small(label)
            }
            .font(.title)
            .foregroundStyle(style.color(for: colorScheme))
        }
    }
    
}

#Preview {
    Component.Button.Secondary("Click me!", style: .default) { }
        .preferredColorScheme(.dark)
}

