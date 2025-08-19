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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("中国語学習")
                            .font(ModernDesignSystem.Typography.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ModernDesignSystem.Colors.text)
                        
                        Text("\(wordData.filteredWords.count)個の単語")
                            .font(ModernDesignSystem.Typography.caption)
                            .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // シンプルな統計表示
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("学習済み")
                            .font(ModernDesignSystem.Typography.caption)
                            .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                        Text("\(wordData.studiedWords.count)")
                            .font(ModernDesignSystem.Typography.headline)
                            .foregroundColor(ModernDesignSystem.Colors.text)
                    }
                }
                
                // シンプルな検索バー
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    
                    TextField("単語を検索...", text: $wordData.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(ModernDesignSystem.Spacing.sm)
                .background(ModernDesignSystem.Colors.background)
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
            }
            .padding(.horizontal, ModernDesignSystem.Spacing.md)
            .padding(.vertical, ModernDesignSystem.Spacing.md)
            .background(Color.white)
            
            Divider()
            
            // シンプルなリスト
            List(wordData.filteredWords, id: \.id) { word in
                NavigationLink(destination: WordDetailPageView(wordData: wordData, selectedWord: word)) {
                    SimpleWordRow(word: word, wordData: wordData)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .listStyle(PlainListStyle())
        }
        .background(ModernDesignSystem.Colors.background)
        .onChange(of: wordData.searchText) { _, _ in
            wordData.updateFilteredWords()
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

#Preview {
    WordListView(wordData: ChineseWordData())
}