//
//  ModernDesignSystem.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

// シンプルなデザインシステム（ミニマリスト）
struct ModernDesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // シンプルカラーパレット
        static let primary = Color.black
        static let secondary = Color.gray
        static let background = Color(.systemBackground)
        static let cardBackground = Color.white
        static let border = Color.gray.opacity(0.3)
        static let accent = Color.blue
        
        // テキストカラー
        static let text = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color.gray
        
        // システムカラー
        static let surface = Color(.systemBackground)
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
    }
    
    // MARK: - Shadow (Minimal)
    struct Shadow {
        static let subtle = (color: Color.black.opacity(0.1), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    }
}

// MARK: - Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Simple UI Components
struct SimpleCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(ModernDesignSystem.Spacing.md)
            .background(Color.white)
            .cornerRadius(ModernDesignSystem.CornerRadius.md)
            .shadow(
                color: ModernDesignSystem.Shadow.subtle.color,
                radius: ModernDesignSystem.Shadow.subtle.radius,
                x: ModernDesignSystem.Shadow.subtle.x,
                y: ModernDesignSystem.Shadow.subtle.y
            )
    }
}

struct SimpleButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, plain
    }
    
    init(title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernDesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                }
                Text(title)
                    .font(ModernDesignSystem.Typography.body)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, ModernDesignSystem.Spacing.sm)
            .background(backgroundColor)
            .cornerRadius(ModernDesignSystem.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
            )
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return ModernDesignSystem.Colors.primary
        case .plain: return ModernDesignSystem.Colors.accent
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return ModernDesignSystem.Colors.primary
        case .secondary: return Color.clear
        case .plain: return Color.clear
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary: return Color.clear
        case .secondary: return ModernDesignSystem.Colors.border
        case .plain: return Color.clear
        }
    }
}