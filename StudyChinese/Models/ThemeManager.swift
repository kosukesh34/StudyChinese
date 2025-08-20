import SwiftUI
import Foundation

// テーマタイプの定義
enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .light:
            return "ライト"
        case .dark:
            return "ダーク"
        }
    }
}

// テーマ管理クラス
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selected_theme"
    
    init() {
        // 保存されたテーマを読み込み、なければライトテーマをデフォルトとする
        let savedTheme = userDefaults.string(forKey: themeKey) ?? AppTheme.light.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .light
    }
    
    private func saveTheme() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
    
    func toggleTheme() {
        currentTheme = currentTheme == .light ? .dark : .light
    }
}

// テーマ対応カラーセット
struct ThemeColors {
    let primary: Color
    let secondary: Color
    let background: Color
    let surface: Color
    let cardBackground: Color
    let text: Color
    let textSecondary: Color
    let accent: Color
    let border: Color
    let shadow: Color
    let success: Color
    let error: Color
    let warning: Color
    
    static let light = ThemeColors(
        primary: Color(red: 0.2, green: 0.6, blue: 1.0),
        secondary: Color(red: 0.5, green: 0.5, blue: 0.5),
        background: Color.white,
        surface: Color(red: 0.98, green: 0.98, blue: 0.98),
        cardBackground: Color.white,
        text: Color.black,
        textSecondary: Color(red: 0.4, green: 0.4, blue: 0.4),
        accent: Color(red: 0.0, green: 0.5, blue: 1.0),
        border: Color(red: 0.9, green: 0.9, blue: 0.9),
        shadow: Color.black.opacity(0.1),
        success: Color.green,
        error: Color.red,
        warning: Color.orange
    )
    
    static let dark = ThemeColors(
        primary: Color(red: 0.3, green: 0.7, blue: 1.0),
        secondary: Color(red: 0.7, green: 0.7, blue: 0.7),
        background: Color(red: 0.05, green: 0.05, blue: 0.05), // ほぼ黒
        surface: Color(red: 0.1, green: 0.1, blue: 0.1),
        cardBackground: Color(red: 0.15, green: 0.15, blue: 0.15),
        text: Color.white,
        textSecondary: Color(red: 0.8, green: 0.8, blue: 0.8),
        accent: Color(red: 0.4, green: 0.8, blue: 1.0),
        border: Color(red: 0.3, green: 0.3, blue: 0.3),
        shadow: Color.black.opacity(0.3),
        success: Color(red: 0.2, green: 0.8, blue: 0.2),
        error: Color(red: 1.0, green: 0.3, blue: 0.3),
        warning: Color(red: 1.0, green: 0.7, blue: 0.2)
    )
    
    static func colors(for theme: AppTheme) -> ThemeColors {
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// Environment用のキー
struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemeColors = .light
}

extension EnvironmentValues {
    var themeColors: ThemeColors {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
