//
//  ContentView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var wordData = ChineseWordData()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // テーマ対応背景
            ThemeColors.colors(for: themeManager.currentTheme).background
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                NavigationView {
                    WordListView(wordData: wordData)
                        .navigationBarHidden(true)
                        .environment(\.themeColors, ThemeColors.colors(for: themeManager.currentTheme))
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(0)
                .tabItem {
                    LuxuryTabItem(
                        icon: "list.bullet.rectangle.portrait",
                        title: "単語リスト",
                        isSelected: selectedTab == 0
                    )
                }
                
                QuizView(wordData: wordData)
                    .environment(\.themeColors, ThemeColors.colors(for: themeManager.currentTheme))
                    .tag(1)
                    .tabItem {
                        LuxuryTabItem(
                            icon: "questionmark.diamond",
                            title: "クイズ",
                            isSelected: selectedTab == 1
                        )
                    }
                
                MemorizationView(wordData: wordData)
                    .environment(\.themeColors, ThemeColors.colors(for: themeManager.currentTheme))
                    .tag(2)
                    .tabItem {
                        LuxuryTabItem(
                            icon: "brain.head.profile",
                            title: "暗記",
                            isSelected: selectedTab == 2
                        )
                    }
                
                SpeechPracticeView(wordData: wordData)
                    .environment(\.themeColors, ThemeColors.colors(for: themeManager.currentTheme))
                    .tag(3)
                    .tabItem {
                        LuxuryTabItem(
                            icon: "waveform.and.mic",
                            title: "音声練習",
                            isSelected: selectedTab == 3
                        )
                    }
                
                StudyProgressView(wordData: wordData)
                    .environment(\.themeColors, ThemeColors.colors(for: themeManager.currentTheme))
                    .environmentObject(themeManager)
                    .tag(4)
                    .tabItem {
                        LuxuryTabItem(
                            icon: "chart.bar.xaxis",
                            title: "学習進捗",
                            isSelected: selectedTab == 4
                        )
                    }
            }
        }
        .accentColor(ThemeColors.colors(for: themeManager.currentTheme).accent)
        .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : .light)
        .onAppear {
            setupWidgetData()
        }
    }
    
    private func setupWidgetData() {
        // ウィジェット用のデータを準備
        DispatchQueue.global(qos: .background).async {
            _ = WidgetDataManager.shared.generateTodaysQuiz(from: wordData.words)
        }
    }
}

// MARK: - Luxury Tab Item
struct LuxuryTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        VStack(spacing: ModernDesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? themeColors.accent : themeColors.textSecondary)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            
            Text(title)
                .font(ModernDesignSystem.Typography.labelSmall)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? themeColors.accent : themeColors.textSecondary)
        }
    }
}

#Preview {
    ContentView()
}