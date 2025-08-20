//
//  LongTextView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/21/25.
//

import SwiftUI

// 長文一覧表示ビュー
struct LongTextView: View {
    @StateObject private var longTextData = ChineseLongTextData()
    @StateObject private var audioPlayer = AudioPlayerManager()
    @Environment(\.themeColors) var themeColors
    @State private var selectedCategory: LongTextCategory? = nil
    @State private var selectedLevel: DifficultyLevel? = nil
    @State private var searchText = ""
    
    var filteredTexts: [ChineseLongText] {
        var texts = longTextData.longTexts
        
        if let category = selectedCategory {
            texts = texts.filter { $0.category == category }
        }
        
        if let level = selectedLevel {
            texts = texts.filter { $0.level == level }
        }
        
        if !searchText.isEmpty {
            texts = texts.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.chineseText.localizedCaseInsensitiveContains(searchText) ||
                $0.japaneseTranslation.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return texts
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ヘッダー
                headerView
                
                // フィルター
                filterView
                
                // 長文リスト
                ScrollView {
                    LazyVStack(spacing: ModernDesignSystem.Spacing.md) {
                        ForEach(filteredTexts) { longText in
                            NavigationLink(destination: LongTextDetailView(longText: longText)) {
                                LongTextCardView(longText: longText)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, ModernDesignSystem.Spacing.md)
                    .padding(.top, ModernDesignSystem.Spacing.sm)
                }
            }
            .background(themeColors.background)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerView: some View {
        VStack(spacing: ModernDesignSystem.Spacing.sm) {
            Text("長文学習")
                .font(ModernDesignSystem.Typography.headlineLarge)
                .fontWeight(.bold)
                .foregroundColor(themeColors.text)
            
            Text("拼音付きで長文を学習しましょう")
                .font(ModernDesignSystem.Typography.bodyMedium)
                .foregroundColor(themeColors.textSecondary)
        }
        .padding(.horizontal, ModernDesignSystem.Spacing.md)
        .padding(.top, ModernDesignSystem.Spacing.lg)
    }
    
    private var filterView: some View {
        VStack(spacing: ModernDesignSystem.Spacing.sm) {
            // 検索バー
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeColors.textSecondary)
                
                TextField("タイトルや内容で検索", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, ModernDesignSystem.Spacing.md)
            .padding(.vertical, ModernDesignSystem.Spacing.sm)
            .background(themeColors.surface)
            .cornerRadius(ModernDesignSystem.CornerRadius.md)
            
            // カテゴリフィルター
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ModernDesignSystem.Spacing.sm) {
                    FilterChip(
                        title: "すべて",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(LongTextCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            icon: category.icon,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, ModernDesignSystem.Spacing.md)
            }
            
            // 難易度フィルター
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ModernDesignSystem.Spacing.sm) {
                    FilterChip(
                        title: "全レベル",
                        isSelected: selectedLevel == nil,
                        action: { selectedLevel = nil }
                    )
                    
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        FilterChip(
                            title: level.displayName,
                            isSelected: selectedLevel == level,
                            color: level.color,
                            action: { selectedLevel = level }
                        )
                    }
                }
                .padding(.horizontal, ModernDesignSystem.Spacing.md)
            }
        }
        .padding(.vertical, ModernDesignSystem.Spacing.md)
        .background(themeColors.background)
    }
}

// フィルターチップ
struct FilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let color: String?
    let action: () -> Void
    
    @Environment(\.themeColors) var themeColors
    
    init(title: String, icon: String? = nil, isSelected: Bool, color: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernDesignSystem.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(ModernDesignSystem.Typography.labelMedium)
            }
            .padding(.horizontal, ModernDesignSystem.Spacing.md)
            .padding(.vertical, ModernDesignSystem.Spacing.sm)
            .background(
                isSelected ? themeColors.accent : themeColors.surface
            )
            .foregroundColor(
                isSelected ? .white : themeColors.text
            )
            .cornerRadius(ModernDesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.lg)
                    .stroke(
                        isSelected ? Color.clear : themeColors.border,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 長文カードビュー
struct LongTextCardView: View {
    let longText: ChineseLongText
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                    Text(longText.title)
                        .font(ModernDesignSystem.Typography.headlineSmall)
                        .fontWeight(.semibold)
                        .foregroundColor(themeColors.text)
                    
                    HStack(spacing: ModernDesignSystem.Spacing.sm) {
                        // カテゴリ
                        HStack(spacing: ModernDesignSystem.Spacing.xs) {
                            Image(systemName: longText.category.icon)
                                .font(.system(size: 12))
                            Text(longText.category.displayName)
                                .font(ModernDesignSystem.Typography.labelSmall)
                        }
                        .padding(.horizontal, ModernDesignSystem.Spacing.sm)
                        .padding(.vertical, ModernDesignSystem.Spacing.xs)
                        .background(themeColors.accent.opacity(0.1))
                        .foregroundColor(themeColors.accent)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                        
                        // 難易度
                        Text(longText.level.displayName)
                            .font(ModernDesignSystem.Typography.labelSmall)
                            .padding(.horizontal, ModernDesignSystem.Spacing.sm)
                            .padding(.vertical, ModernDesignSystem.Spacing.xs)
                            .background(getDifficultyColor(longText.level).opacity(0.1))
                            .foregroundColor(getDifficultyColor(longText.level))
                            .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeColors.textSecondary)
            }
            
            // プレビューテキスト（中国語）
            VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                Text(String(longText.chineseText.prefix(100)) + (longText.chineseText.count > 100 ? "..." : ""))
                    .font(ModernDesignSystem.Typography.bodyMedium)
                    .foregroundColor(themeColors.text)
                    .lineLimit(3)
                    .lineSpacing(2)
                
                // 拼音プレビュー
                Text(String(longText.pinyinText.prefix(120)) + (longText.pinyinText.count > 120 ? "..." : ""))
                    .font(ModernDesignSystem.Typography.bodySmall)
                    .foregroundColor(themeColors.accent)
                    .lineLimit(2)
                    .lineSpacing(1)
            }
            
            // 統計情報
            HStack(spacing: ModernDesignSystem.Spacing.lg) {
                HStack(spacing: ModernDesignSystem.Spacing.xs) {
                    Image(systemName: "textformat.characters")
                        .font(.system(size: 12))
                    Text("\(longText.chineseText.count)文字")
                        .font(ModernDesignSystem.Typography.labelSmall)
                }
                
                HStack(spacing: ModernDesignSystem.Spacing.xs) {
                    Image(systemName: "key")
                        .font(.system(size: 12))
                    Text("\(longText.keyWords.count)重要語")
                        .font(ModernDesignSystem.Typography.labelSmall)
                }
                
                HStack(spacing: ModernDesignSystem.Spacing.xs) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 12))
                    Text("\(longText.exerciseQuestions.count)問題")
                        .font(ModernDesignSystem.Typography.labelSmall)
                }
                
                Spacer()
            }
            .foregroundColor(themeColors.textSecondary)
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.surface)
        .cornerRadius(ModernDesignSystem.CornerRadius.lg)
        .shadow(
            color: themeColors.text.opacity(0.1),
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
    
    private func getDifficultyColor(_ level: DifficultyLevel) -> Color {
        switch level.color {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
}

#Preview {
    LongTextView()
        .environment(\.themeColors, ThemeColors.colors(for: .light))
}
