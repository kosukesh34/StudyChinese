//
//  WordListView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct WordListView: View {
    @ObservedObject var wordData: ChineseWordData
    
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
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                }
                
                // プレミアム検索バー
                LuxurySearchBar(searchText: $wordData.searchText)
            }
            .padding(.horizontal, ModernDesignSystem.Spacing.md)
            .padding(.top, ModernDesignSystem.Spacing.md)
            .padding(.bottom, ModernDesignSystem.Spacing.sm)
            .background(Color.white)
            
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
        .background(ModernDesignSystem.Colors.background)
        .onChange(of: wordData.searchText) { _, _ in
            wordData.updateFilteredWords()
        }
    }
}

// MARK: - Luxury Stats View
struct LuxuryStatsView: View {
    let studiedCount: Int
    let favoriteCount: Int
    
    var body: some View {
        HStack(spacing: ModernDesignSystem.Spacing.md) {
            StatBadge(
                icon: "checkmark.circle.fill",
                value: "\(studiedCount)",
                label: "学習済み",
                color: ModernDesignSystem.Colors.success
            )
            
            StatBadge(
                icon: "heart.fill",
                value: "\(favoriteCount)",
                label: "お気に入り",
                color: ModernDesignSystem.Colors.accent
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
    
    var body: some View {
        VStack(spacing: ModernDesignSystem.Spacing.xs) {
            HStack(spacing: ModernDesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
                
                Text(value)
                    .font(ModernDesignSystem.Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(ModernDesignSystem.Colors.textPrimary)
            }
            
            Text(label)
                .font(ModernDesignSystem.Typography.labelSmall)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
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
    
    var body: some View {
        HStack(spacing: ModernDesignSystem.Spacing.md) {
            HStack(spacing: ModernDesignSystem.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                
                TextField("単語を検索...", text: $searchText)
                    .font(ModernDesignSystem.Typography.bodyMedium)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, ModernDesignSystem.Spacing.md)
            .padding(.vertical, ModernDesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.md)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.md)
                            .stroke(ModernDesignSystem.Colors.border, lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Simple Word Row
struct SimpleWordRow: View {
    let word: ChineseWord
    @ObservedObject var wordData: ChineseWordData
    
    var body: some View {
        HStack(spacing: ModernDesignSystem.Spacing.md) {
            // シンプルな番号表示
            Text(word.number)
                .font(ModernDesignSystem.Typography.caption)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                .frame(width: 30, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(ModernDesignSystem.Colors.text)
                
                Text(word.pronunciation)
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(ModernDesignSystem.Colors.accent)
                
                Text(word.meaning)
                    .font(ModernDesignSystem.Typography.body)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
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
        .background(Color.white)
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
                        .foregroundColor(ModernDesignSystem.Colors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                    // メイン単語
                    Text(word.word)
                        .font(ModernDesignSystem.Typography.titleLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(ModernDesignSystem.Colors.textPrimary)
                    
                    // 発音（拼音）
                    HStack(spacing: ModernDesignSystem.Spacing.xs) {
                        Image(systemName: "speaker.wave.1")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ModernDesignSystem.Colors.accent)
                        
                        Text(word.pronunciation)
                            .font(ModernDesignSystem.Typography.bodySmall)
                            .foregroundColor(ModernDesignSystem.Colors.accent)
                    }
                    
                    // 意味
                    Text(word.meaning)
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // プレミアムステータス表示
                VStack(spacing: ModernDesignSystem.Spacing.xs) {
                    if wordData.isStudied(word: word) {
                        StatusBadge(
                            icon: "checkmark.circle.fill",
                            color: ModernDesignSystem.Colors.success,
                            type: .studied
                        )
                    }
                    
                    if wordData.isFavorite(word: word) {
                        StatusBadge(
                            icon: "heart.fill",
                            color: ModernDesignSystem.Colors.accent,
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