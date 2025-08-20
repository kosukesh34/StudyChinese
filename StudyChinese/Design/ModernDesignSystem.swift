//
//  ModernDesignSystem.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

// 高級感のあるプレミアムデザインシステム
struct ModernDesignSystem {
    
    // MARK: - Luxury Colors
    struct Colors {
        // プレミアムカラーパレット
        static let deepCharcoal = Color(hex: "1C1C1E")
        static let richBlack = Color(hex: "000000")
        static let premiumGold = Color(hex: "D4AF37")
        static let elegantSilver = Color(hex: "C0C0C0")
        static let luxuryBronze = Color(hex: "CD7F32")
        
        // メインカラー
        static let primary = deepCharcoal
        static let secondary = elegantSilver
        static let accent = premiumGold
        
        // 背景
        static let background = Color(hex: "F8F9FA")
        static let cardBackground = Color.white
        static let surfaceElevated = Color(hex: "FFFFFF")
        static let surface = Color(hex: "F8F9FA")
        
        // テキスト
        static let textPrimary = deepCharcoal
        static let textSecondary = Color(hex: "6C757D")
        static let textTertiary = Color(hex: "ADB5BD")
        static let textOnDark = Color.white
        static let text = textPrimary
        
        // プレミアムアクセント
        static let goldGradientStart = Color(hex: "FFD700")
        static let goldGradientEnd = Color(hex: "B8860B")
        static let silverGradientStart = Color(hex: "E5E5E5")
        static let silverGradientEnd = Color(hex: "A8A8A8")
        
        // ステータス
        static let success = Color(hex: "28A745")
        static let error = Color(hex: "DC3545")
        static let warning = Color(hex: "FFC107")
        static let info = Color(hex: "17A2B8")
        
        // ボーダー
        static let border = Color(hex: "E9ECEF")
        static let borderAccent = premiumGold.opacity(0.3)
    }
    
    // MARK: - Luxury Gradients
    struct Gradients {
        static let primaryGold = LinearGradient(
            colors: [Colors.goldGradientStart, Colors.goldGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let elegantSilver = LinearGradient(
            colors: [Colors.silverGradientStart, Colors.silverGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let premiumDark = LinearGradient(
            colors: [Colors.deepCharcoal, Colors.richBlack],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let subtleElevation = LinearGradient(
            colors: [Color.white, Color(hex: "F8F9FA")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Luxury Typography
    struct Typography {
        // プレミアムフォント階層
        static let displayLarge = Font.system(size: 57, weight: .bold, design: .default)
        static let displayMedium = Font.system(size: 45, weight: .bold, design: .default)
        static let displaySmall = Font.system(size: 36, weight: .bold, design: .default)
        
        static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)
        static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)
        static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)
        
        static let titleLarge = Font.system(size: 22, weight: .medium, design: .default)
        static let titleMedium = Font.system(size: 16, weight: .medium, design: .default)
        static let titleSmall = Font.system(size: 14, weight: .medium, design: .default)
        
        static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
        
        static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
        static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
        static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
        
        // 後方互換性
        static let largeTitle = displayLarge
        static let title = headlineLarge
        static let title2 = headlineMedium
        static let title3 = headlineSmall
        static let headline = titleLarge
        static let body = bodyMedium
        static let callout = bodyLarge
        static let subheadline = bodyMedium
        static let footnote = bodySmall
        static let caption = labelSmall
    }
    
    // MARK: - Refined Spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Elegant Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let round: CGFloat = 50
    }
    
    // MARK: - Luxury Shadows
    struct Shadow {
        // エレベーション1 - 微細
        static let elevation1 = (
            color: Color.black.opacity(0.08),
            radius: CGFloat(1),
            x: CGFloat(0),
            y: CGFloat(1)
        )
        
        // エレベーション2 - 軽い
        static let elevation2 = (
            color: Color.black.opacity(0.12),
            radius: CGFloat(2),
            x: CGFloat(0),
            y: CGFloat(2)
        )
        
        // エレベーション3 - 中程度
        static let elevation3 = (
            color: Color.black.opacity(0.16),
            radius: CGFloat(4),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        
        // エレベーション4 - 強い
        static let elevation4 = (
            color: Color.black.opacity(0.20),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(8)
        )
        
        // エレベーション5 - 最高
        static let elevation5 = (
            color: Color.black.opacity(0.24),
            radius: CGFloat(16),
            x: CGFloat(0),
            y: CGFloat(16)
        )
        
        // ゴールドグロー
        static let goldGlow = (
            color: Colors.premiumGold.opacity(0.3),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        
        // 後方互換性
        static let subtle = elevation1
        static let medium = elevation3
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

// MARK: - Luxury UI Components
struct LuxuryCard<Content: View>: View {
    let content: Content
    let elevation: CardElevation
    @Environment(\.themeColors) var themeColors
    
    enum CardElevation {
        case low, medium, high, premium
    }
    
    init(elevation: CardElevation = .medium, @ViewBuilder content: () -> Content) {
        self.elevation = elevation
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(ModernDesignSystem.Spacing.lg)
            .background(cardBackground)
            .cornerRadius(ModernDesignSystem.CornerRadius.lg)
            .shadow(
                color: shadowStyle.color,
                radius: shadowStyle.radius,
                x: shadowStyle.x,
                y: shadowStyle.y
            )
    }
    
    private var cardBackground: some View {
        Group {
            switch elevation {
            case .low:
                themeColors.cardBackground
            case .medium:
                themeColors.cardBackground
            case .high:
                themeColors.cardBackground
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.lg)
                            .stroke(themeColors.accent, lineWidth: 1)
                    )
            case .premium:
                themeColors.cardBackground
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.lg)
                            .stroke(themeColors.accent, lineWidth: 2)
                    )
            }
        }
    }
    
    private var shadowStyle: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch elevation {
        case .low: return ModernDesignSystem.Shadow.elevation1
        case .medium: return ModernDesignSystem.Shadow.elevation2
        case .high: return ModernDesignSystem.Shadow.elevation3
        case .premium: return ModernDesignSystem.Shadow.goldGlow
        }
    }
}

struct LuxuryButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, premium, ghost
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
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(ModernDesignSystem.Typography.titleMedium)
                    .fontWeight(.medium)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, ModernDesignSystem.Spacing.md)
            .padding(.horizontal, ModernDesignSystem.Spacing.lg)
            .background(buttonBackground)
            .cornerRadius(ModernDesignSystem.CornerRadius.md)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: style)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return ModernDesignSystem.Colors.textOnDark
        case .secondary: return ModernDesignSystem.Colors.textPrimary
        case .premium: return ModernDesignSystem.Colors.textOnDark
        case .ghost: return ModernDesignSystem.Colors.accent
        }
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        switch style {
        case .primary:
            ModernDesignSystem.Gradients.premiumDark
        case .secondary:
            Color.white
                .overlay(
                    RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.md)
                        .stroke(ModernDesignSystem.Colors.border, lineWidth: 1)
                )
        case .premium:
            ModernDesignSystem.Gradients.primaryGold
        case .ghost:
            Color.clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary: return Color.black.opacity(0.15)
        case .secondary: return Color.black.opacity(0.08)
        case .premium: return ModernDesignSystem.Colors.premiumGold.opacity(0.3)
        case .ghost: return Color.clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary, .premium: return 4
        case .secondary: return 2
        case .ghost: return 0
        }
    }
    
    private var shadowY: CGFloat {
        switch style {
        case .primary, .premium: return 2
        case .secondary: return 1
        case .ghost: return 0
        }
    }
}

// MARK: - 後方互換性のためのエイリアス
typealias SimpleCard = LuxuryCard
typealias SimpleButton = LuxuryButton