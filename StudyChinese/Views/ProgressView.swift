//
//  ProgressView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct StudyProgressView: View {
    @ObservedObject var wordData: ChineseWordData
    @StateObject private var studyDataManager = StudyDataManager.shared
    @State private var showingNotificationSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: ModernDesignSystem.Spacing.lg) {
                    // シンプルな進捗サマリー
                    progressSummarySection
                    
                    // シンプルな統計
                    statisticsSection
                    
                    // 設定セクション
                    settingsSection
                    
                    // お気に入り単語
                    if !wordData.favoriteWords.isEmpty {
                        favoriteWordsSection
                    }
                }
                .padding(ModernDesignSystem.Spacing.md)
            }
            .background(ModernDesignSystem.Colors.background)
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
    }
    
    // MARK: - Progress Summary Section
    private var progressSummarySection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            Text("全体の進捗")
                .font(ModernDesignSystem.Typography.headline)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            // シンプルなプログレスバー
            VStack(spacing: 8) {
                HStack {
                    Text("学習済み")
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    Spacer()
                    Text("\(wordData.studiedWords.count) / \(wordData.words.count)")
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(ModernDesignSystem.Colors.text)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(ModernDesignSystem.Colors.border)
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(ModernDesignSystem.Colors.success)
                            .frame(
                                width: geometry.size.width * progressPercentage,
                                height: 8
                            )
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text("\(Int(progressPercentage * 100))% 完了")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
            }
        }
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
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            Text("統計")
                .font(ModernDesignSystem.Typography.headline)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            // 基本統計
            HStack(spacing: ModernDesignSystem.Spacing.md) {
                StatItem(
                    title: "総単語数",
                    value: "\(wordData.words.count)",
                    icon: "book"
                )
                
                StatItem(
                    title: "学習済み",
                    value: "\(wordData.studiedWords.count)",
                    icon: "checkmark.circle"
                )
                
                StatItem(
                    title: "お気に入り",
                    value: "\(wordData.favoriteWords.count)",
                    icon: "heart"
                )
            }
            
            Divider()
                .padding(.vertical, ModernDesignSystem.Spacing.sm)
            
            // 詳細統計
            VStack(spacing: ModernDesignSystem.Spacing.sm) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(ModernDesignSystem.Colors.accent)
                    Text("学習ストリーク")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                    Spacer()
                    Text("\(studyDataManager.getStudyStreak())日")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "questionmark.diamond")
                        .foregroundColor(ModernDesignSystem.Colors.accent)
                    Text("クイズ正答率")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                    Spacer()
                    Text("\(Int(studyDataManager.quizStats.accuracy * 100))%")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "waveform.and.mic")
                        .foregroundColor(ModernDesignSystem.Colors.accent)
                    Text("音声練習精度")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                    Spacer()
                    Text("\(Int(studyDataManager.speechPracticeStats.averageAccuracy * 100))%")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(ModernDesignSystem.Colors.accent)
                    Text("暗記カード正答率")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                    Spacer()
                    Text("\(Int(studyDataManager.memorizationStats.accuracy * 100))%")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .fontWeight(.semibold)
                }
            }
        }
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
    
    // MARK: - Favorite Words Section
    private var favoriteWordsSection: some View {
        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
            Text("お気に入り単語")
                .font(ModernDesignSystem.Typography.headline)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ModernDesignSystem.Spacing.sm) {
                    ForEach(favoriteWords.prefix(10), id: \.id) { word in
                        SimpleWordCard(word: word)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
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
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
            Text("設定")
                .font(ModernDesignSystem.Typography.headline)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            VStack(spacing: ModernDesignSystem.Spacing.sm) {
                Button(action: {
                    showingNotificationSettings = true
                }) {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(ModernDesignSystem.Colors.accent)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("学習リマインダー")
                                .font(ModernDesignSystem.Typography.bodyMedium)
                                .foregroundColor(ModernDesignSystem.Colors.text)
                            
                            Text("毎日の学習習慣をサポート")
                                .font(ModernDesignSystem.Typography.bodySmall)
                                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    }
                    .padding(ModernDesignSystem.Spacing.md)
                    .background(Color.white)
                    .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                            .stroke(ModernDesignSystem.Colors.border, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // ウィジェット設定の説明
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                    HStack {
                        Image(systemName: "widget.small")
                            .foregroundColor(ModernDesignSystem.Colors.accent)
                            .frame(width: 24)
                        
                        Text("ウィジェット")
                            .font(ModernDesignSystem.Typography.bodyMedium)
                            .foregroundColor(ModernDesignSystem.Colors.text)
                        
                        Spacer()
                    }
                    
                    Text("ホーム画面にウィジェットを追加すると、毎日新しい中国語クイズが表示されます。ウィジェットをタップするとアプリが起動します。")
                        .font(ModernDesignSystem.Typography.bodySmall)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                        .padding(.leading, 32)
                }
                .padding(ModernDesignSystem.Spacing.md)
                .background(ModernDesignSystem.Colors.accent.opacity(0.05))
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                        .stroke(ModernDesignSystem.Colors.accent.opacity(0.2), lineWidth: 1)
                )
            }
        }
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

    // MARK: - Computed Properties
    private var progressPercentage: Double {
        wordData.words.count > 0 ? Double(wordData.studiedWords.count) / Double(wordData.words.count) : 0.0
    }
    
    private var favoriteWords: [ChineseWord] {
        wordData.words.filter { wordData.isFavorite(word: $0) }
    }
}

// MARK: - Supporting Views
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(ModernDesignSystem.Colors.accent)
            
            Text(value)
                .font(ModernDesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            Text(title)
                .font(ModernDesignSystem.Typography.caption)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SimpleWordCard: View {
    let word: ChineseWord
    
    var body: some View {
        VStack(spacing: 4) {
            Text(word.word)
                .font(ModernDesignSystem.Typography.headline)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            Text(word.meaning)
                .font(ModernDesignSystem.Typography.caption)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(ModernDesignSystem.Spacing.sm)
        .background(ModernDesignSystem.Colors.background)
        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
        .frame(width: 100, height: 80)
    }
}

#Preview {
    StudyProgressView(wordData: ChineseWordData())
}