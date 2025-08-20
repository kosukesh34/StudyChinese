//
//  WordListView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct WordListView: View {
    @ObservedObject var wordData: ChineseWordData
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        VStack(spacing: 0) {
            // シンプルなヘッダー
            VStack(spacing: ModernDesignSystem.Spacing.md) {
                HStack {
                    // エレガントな統計表示
                    LuxuryStatsView(
                        studiedCount: wordData.studiedWords.count,
                        favoriteCount: wordData.favoriteWords.count
                    )
                    
                    Spacer()
                    
                    Text("\(wordData.filteredWords.count)個の単語")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .foregroundColor(themeColors.textSecondary)
                }
                
                // プレミアム検索バー
                LuxurySearchBar(searchText: $wordData.searchText)
            }
            .padding(.horizontal, ModernDesignSystem.Spacing.md)
            .padding(.top, ModernDesignSystem.Spacing.md)
            .padding(.bottom, ModernDesignSystem.Spacing.sm)
            .background(themeColors.surface)
            
            Divider()
            
            // プレミアムリスト
            ScrollView {
                LazyVStack(spacing: ModernDesignSystem.Spacing.sm) {
                    ForEach(wordData.filteredWords, id: \.id) { word in
                        NavigationLink(destination: WordDetailPageView(wordData: wordData, selectedWord: word)) {
                            LuxuryWordRow(word: word, wordData: wordData)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                .padding(.vertical, ModernDesignSystem.Spacing.sm)
            }
        }
        .background(themeColors.background)
        .onChange(of: wordData.searchText) { _, _ in
            wordData.updateFilteredWords()
        }
    }
}

// MARK: - Luxury Stats View
struct LuxuryStatsView: View {
    let studiedCount: Int
    let favoriteCount: Int
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        HStack(spacing: ModernDesignSystem.Spacing.md) {
            StatBadge(
                icon: "checkmark.circle.fill",
                value: "\(studiedCount)",
                label: "学習済み",
                color: themeColors.success
            )
            
            StatBadge(
                icon: "heart.fill",
                value: "\(favoriteCount)",
                label: "お気に入り",
                color: themeColors.accent
            )
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        VStack(spacing: ModernDesignSystem.Spacing.xs) {
            HStack(spacing: ModernDesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
                
                Text(value)
                    .font(ModernDesignSystem.Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(themeColors.text)
            }
            
            Text(label)
                .font(ModernDesignSystem.Typography.labelSmall)
                .foregroundColor(themeColors.textSecondary)
        }
        .padding(.vertical, ModernDesignSystem.Spacing.xs)
        .padding(.horizontal, ModernDesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Luxury Search Bar
struct LuxurySearchBar: View {
    @Binding var searchText: String
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        HStack(spacing: ModernDesignSystem.Spacing.md) {
            HStack(spacing: ModernDesignSystem.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeColors.textSecondary)
                
                TextField("単語を検索...", text: $searchText)
                    .font(ModernDesignSystem.Typography.bodyMedium)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, ModernDesignSystem.Spacing.md)
            .padding(.vertical, ModernDesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.md)
                    .fill(themeColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.md)
                            .stroke(themeColors.border, lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Simple Word Row
struct SimpleWordRow: View {
    let word: ChineseWord
    @ObservedObject var wordData: ChineseWordData
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        HStack(spacing: ModernDesignSystem.Spacing.md) {
            // シンプルな番号表示
            Text(word.number)
                .font(ModernDesignSystem.Typography.caption)
                .foregroundColor(themeColors.textSecondary)
                .frame(width: 30, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(themeColors.text)
                
                Text(word.pronunciation)
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(themeColors.accent)
                
                Text(word.meaning)
                    .font(ModernDesignSystem.Typography.body)
                    .foregroundColor(themeColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // シンプルな状態表示
            VStack(spacing: 4) {
                if wordData.isFavorite(word: word) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                
                if wordData.isStudied(word: word) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, ModernDesignSystem.Spacing.sm)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
}

// MARK: - Luxury Word Row
struct LuxuryWordRow: View {
    let word: ChineseWord
    @ObservedObject var wordData: ChineseWordData
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        LuxuryCard(elevation: .low) {
            HStack(spacing: ModernDesignSystem.Spacing.md) {
                // エレガントな番号バッジ
                ZStack {
                    Circle()
                        .fill(ModernDesignSystem.Gradients.elegantSilver)
                        .frame(width: 36, height: 36)
                    
                    Text(word.number)
                        .font(ModernDesignSystem.Typography.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(themeColors.text)
                }
                
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                    // メイン単語
                    Text(word.word)
                        .font(ModernDesignSystem.Typography.titleLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(themeColors.text)
                    
                    // 発音（拼音）
                    HStack(spacing: ModernDesignSystem.Spacing.xs) {
                        Image(systemName: "speaker.wave.1")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeColors.accent)
                        
                        Text(word.pronunciation)
                            .font(ModernDesignSystem.Typography.bodySmall)
                            .foregroundColor(themeColors.accent)
                    }
                    
                    // 意味
                    Text(word.meaning)
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .foregroundColor(themeColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // プレミアムステータス表示
                VStack(spacing: ModernDesignSystem.Spacing.xs) {
                    if wordData.isStudied(word: word) {
                        StatusBadge(
                            icon: "checkmark.circle.fill",
                            color: themeColors.success,
                            type: .studied
                        )
                    }
                    
                    if wordData.isFavorite(word: word) {
                        StatusBadge(
                            icon: "heart.fill",
                            color: themeColors.accent,
                            type: .favorite
                        )
                    }
                }
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let icon: String
    let color: Color
    let type: BadgeType
    
    enum BadgeType {
        case studied, favorite
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 28, height: 28)
            
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
        }
        .shadow(
            color: ModernDesignSystem.Shadow.elevation1.color,
            radius: ModernDesignSystem.Shadow.elevation1.radius,
            x: ModernDesignSystem.Shadow.elevation1.x,
            y: ModernDesignSystem.Shadow.elevation1.y
        )
    }
}

#Preview {
    WordListView(wordData: ChineseWordData())
}