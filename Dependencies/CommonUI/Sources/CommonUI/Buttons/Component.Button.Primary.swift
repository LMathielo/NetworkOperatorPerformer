//
//  Component.Button.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 27/06/24.
//

import SwiftUI

extension Component.Button {
    
    public struct Primary: View {
        @Environment(\.colorScheme) private var colorScheme
        
        private let icon: String?
        private let label: String
        private let action: () -> Void
        
        public init(
            _ label: String,
            _ icon: String? = nil,
            action: @escaping () -> Void
        ) {
            self.label = label
            self.icon = icon
            self.action = action
        }
        
        public var body: some View {
            SwiftUI.Button {
                action()
            } label: {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                    Component.Text.Small(label)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(colorScheme == .light ? .blue : .white)
            .font(.title)
            .padding()
            .foregroundStyle(colorScheme == .light ? .white : .black)
        }
    }
    
}

#Preview {
    Component.Button.Primary("Cancel") { }
        .preferredColorScheme(.light)
}

#Preview {
    Component.Button.Primary("Cancel") { }
        .preferredColorScheme(.dark)
}
