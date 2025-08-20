//
//  StudyPracticeView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/21/25.
//

import SwiftUI

// クイズと暗記を統合した学習練習ビュー
struct StudyPracticeView: View {
    let wordData: ChineseWordData
    @Environment(\.themeColors) var themeColors
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            headerView
            
            // タブセレクタ
            tabSelector
            
            // タブコンテンツ
            TabView(selection: $selectedTab) {
                // クイズタブ
                QuizView(wordData: wordData)
                    .tag(0)
                
                // 暗記タブ
                MemorizationView(wordData: wordData)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(themeColors.background)
    }
    
    private var headerView: some View {
        VStack(spacing: ModernDesignSystem.Spacing.sm) {
            Text("学習練習")
                .font(ModernDesignSystem.Typography.headlineLarge)
                .fontWeight(.bold)
                .foregroundColor(themeColors.text)
            
            Text("クイズと暗記で中国語をマスター")
                .font(ModernDesignSystem.Typography.bodyMedium)
                .foregroundColor(themeColors.textSecondary)
        }
        .padding(.horizontal, ModernDesignSystem.Spacing.md)
        .padding(.top, ModernDesignSystem.Spacing.lg)
        .padding(.bottom, ModernDesignSystem.Spacing.md)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<2) { index in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: ModernDesignSystem.Spacing.xs) {
                        HStack(spacing: ModernDesignSystem.Spacing.xs) {
                            Image(systemName: getTabIcon(index))
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(getTabTitle(index))
                                .font(ModernDesignSystem.Typography.labelMedium)
                                .fontWeight(selectedTab == index ? .semibold : .medium)
                        }
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == index ? themeColors.accent : Color.clear)
                    }
                }
                .foregroundColor(selectedTab == index ? themeColors.accent : themeColors.textSecondary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, ModernDesignSystem.Spacing.md)
        .background(themeColors.surface)
    }
    
    private func getTabTitle(_ index: Int) -> String {
        switch index {
        case 0: return "クイズ"
        case 1: return "暗記"
        default: return ""
        }
    }
    
    private func getTabIcon(_ index: Int) -> String {
        switch index {
        case 0: return "questionmark.diamond"
        case 1: return "brain.head.profile"
        default: return ""
        }
    }
}

#Preview {
    StudyPracticeView(wordData: ChineseWordData())
        .environment(\.themeColors, ThemeColors.colors(for: .light))
}
