//
//  Tokens.swift
//  
//
//  Created by Lucas Mathielo on 29/06/24.
//

import Foundation
import SwiftUI

protocol ButtonsDesignSystem {
    var tint: Color { get }
    var foreground: Color? { get }
    var shadowColor: Color? { get }
    var border: CGFloat? { get }
}

protocol TextsDesignSystem {
    var font: Font { get }
    var tintColor: Color { get }
}

enum Tokens {
    enum Button {
        case primary(Primary)
        case secondary(Secondary)
    }
    
    enum Text {
        case small(Small)
        case medium(Medium)
        case large(Large)
    }
}

extension Tokens.Button {
    enum Primary: ButtonsDesignSystem {
        case light
        case dark
        
        var tint: Color {
            switch self {
            case .light: return .blue
            case .dark: return .white
            }
        }
        
        var foreground: Color? {
            switch self {
            case .light: return .white
            case .dark: return .black
            }
        }
        
        var shadowColor: Color? {
            switch self {
            case .light: return .black
            case .dark: return .white
            }
        }
        
        var border: CGFloat? { 12 }
    }
    
    enum Secondary: ButtonsDesignSystem {
        case light
        case dark
        
        var tint: Color {
            switch self {
            case .light: return .black
            case .dark: return .white
            }
        }
        
        var foreground: Color? { nil }
        
        var shadowColor: Color? { nil }
        
        var border: CGFloat? { nil }
    }
}

extension Tokens.Text {
    enum Small: TextsDesignSystem {
        case light
        case dark
        
        var font: Font { .title3 }
        
        var tintColor: Color {
            switch self {
            case .light: return .black
            case .dark: return .white
            }
        }
    }
    
    enum Medium: TextsDesignSystem {
        case light
        case dark
        
        var font: Font { .title }
        
        var tintColor: Color {
            switch self {
            case .light: return .black
            case .dark: return .white
            }
        }
    }
    
    enum Large: TextsDesignSystem {
        case light
        case dark
        
        var font: Font { .largeTitle }
        
        var tintColor: Color {
            switch self {
            case .light: return .black
            case .dark: return .white
            }
        }
    }
}

extension Tokens {
    enum Color {
        case white
        case black
        case red
        case blue
        
        var rawValue: SwiftUI.Color {
            switch self {
            case .white: return .white
            case .black: return .black
            case .red: return .red
            case .blue: return .blue
            }
        }
    }
}
