//
//  View+Extensions.swift
//  
//
//  Created by Lucas Mathielo on 30/06/24.
//

import SwiftUI

extension View {
    @ViewBuilder func ifForegroundStyle(_ color: Color?) -> some View {
        if let color {
            self.foregroundStyle(color)
        } else {
            self
        }
    }
    
    @ViewBuilder func ifCornerRadius(_ border: CGFloat?) -> some View {
        if let border {
            self.cornerRadius(border)
        } else {
            self
        }
    }
}
