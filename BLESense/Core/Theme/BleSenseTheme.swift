//
//  BleSenseTheme.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Design tokens, modern color palette, gradients, and UI styles matching BLESense Android.
//

import SwiftUI

public struct BleSenseColors {
    // Primary Brand Accents
    public static let primaryGreen = Color(red: 0x00/255.0, green: 0xD4/255.0, blue: 0xA0/255.0)
    public static let primaryGreenDark = Color(red: 0x00/255.0, green: 0xB8/255.0, blue: 0x89/255.0)
    public static let primaryGreenLight = Color(red: 0x33/255.0, green: 0xE6/255.0, blue: 0xB3/255.0)
    
    // Light Theme Tokens
    public static let lightBackground = Color(red: 0xF2/255.0, green: 0xF5/255.0, blue: 0xF9/255.0)
    public static let lightSurface = Color.white
    public static let lightBorder = Color(red: 0xE2/255.0, green: 0xEE/255.0, blue: 0xF9/255.0)
    public static let lightTextPrimary = Color(red: 0x0F/255.0, green: 0x17/255.0, blue: 0x2A/255.0)
    public static let lightTextSecondary = Color(red: 0x64/255.0, green: 0x74/255.0, blue: 0x8B/255.0)
    
    // Dark Theme Tokens (Refined Charcoal / Obsidian)
    public static let backgroundDark = Color(red: 0x0D/255.0, green: 0x0D/255.0, blue: 0x12/255.0)
    public static let surfaceDark = Color(red: 0x18/255.0, green: 0x18/255.0, blue: 0x20/255.0)
    public static let surfaceLight = Color(red: 0x22/255.0, green: 0x22/255.0, blue: 0x2C/255.0)
    public static let cardDark = Color(red: 0x18/255.0, green: 0x18/255.0, blue: 0x20/255.0)
    public static let borderDark = Color(red: 0x2C/255.0, green: 0x2C/255.0, blue: 0x38/255.0)
    
    // Text colors
    public static let textPrimary = Color.white
    public static let textSecondary = Color(red: 0xA1/255.0, green: 0xA1/255.0, blue: 0xAA/255.0)
    public static let textTertiary = Color(red: 0x71/255.0, green: 0x71/255.0, blue: 0x7A/255.0)
    
    // Status & Accent
    public static let bluetoothBlue = Color(red: 0x3B/255.0, green: 0x82/255.0, blue: 0xF6/255.0)
    public static let warningOrange = Color(red: 0xFF/255.0, green: 0x8C/255.0, blue: 0x42/255.0)
    public static let errorRed = Color(red: 0xFF/255.0, green: 0x5E/255.0, blue: 0x5E/255.0)
    public static let yellowAccent = Color(red: 0xFB/255.0, green: 0xBF/255.0, blue: 0x24/255.0)
    public static let purpleAccent = Color(red: 0xA7/255.0, green: 0x8B/255.0, blue: 0xFA/255.0)
    public static let tealAccent = Color(red: 0x08/255.0, green: 0x91/255.0, blue: 0xB2/255.0)
    
    // Badges
    public static let greenBadgeBg = Color(red: 0xD1/255.0, green: 0xFA/255.0, blue: 0xE5/255.0)
    public static let greenBadgeText = Color(red: 0x06/255.0, green: 0x5F/255.0, blue: 0x46/255.0)
    public static let cyanBadgeBg = Color(red: 0xCF/255.0, green: 0xFA/255.0, blue: 0xFE/255.0)
    public static let cyanBadgeText = Color(red: 0x15/255.0, green: 0x5E/255.0, blue: 0x75/255.0)
}

public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @AppStorage("isDarkMode") public var isDarkMode: Bool = true
    
    public var backgroundColor: Color {
        isDarkMode ? BleSenseColors.backgroundDark : BleSenseColors.lightBackground
    }
    
    public var surfaceColor: Color {
        isDarkMode ? BleSenseColors.surfaceDark : BleSenseColors.lightSurface
    }
    
    public var borderColor: Color {
        isDarkMode ? BleSenseColors.borderDark : BleSenseColors.lightBorder
    }
    
    public var textPrimaryColor: Color {
        isDarkMode ? BleSenseColors.textPrimary : BleSenseColors.lightTextPrimary
    }
    
    public var textSecondaryColor: Color {
        isDarkMode ? BleSenseColors.textSecondary : BleSenseColors.lightTextSecondary
    }
}

// MARK: - View Modifiers
public struct ModernCardModifier: ViewModifier {
    @ObservedObject var theme = ThemeManager.shared
    var cornerRadius: CGFloat = 20
    var borderColor: Color? = nil
    
    public func body(content: Content) -> some View {
        content
            .background(theme.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor ?? theme.borderColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(theme.isDarkMode ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
    }
}

public extension View {
    func modernCard(cornerRadius: CGFloat = 20, borderColor: Color? = nil) -> some View {
        self.modifier(ModernCardModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }
}
