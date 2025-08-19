//
//  MemorizationView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct MemorizationView: View {
    @ObservedObject var wordData: ChineseWordData
    @State private var currentCardIndex: Int = 0
    @State private var showAnswer: Bool = false
    @State private var cards: [ChineseWord] = []
    @State private var memorizedCount: Int = 0
    @State private var studyMode: StudyMode = .unstudiedOnly
    @State private var showingModeSelection = false
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    enum StudyMode: String, CaseIterable {
        case unstudiedOnly = "未学習のみ"
        case favorites = "お気に入り"
        case all = "全ての単語"
        case random = "ランダム50単語"
        
        var description: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // シンプルなヘッダー
            headerSection
                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                .padding(.vertical, ModernDesignSystem.Spacing.md)
                .background(Color.white)
            
            Divider()
            
            if !cards.isEmpty {
                VStack(spacing: ModernDesignSystem.Spacing.lg) {
                    // シンプルな進捗表示
                    progressSection
                        .padding(.horizontal, ModernDesignSystem.Spacing.md)
                    
                    // シンプルなフラッシュカード
                    cardSection
                        .padding(.horizontal, ModernDesignSystem.Spacing.md)
                    
                    // シンプルなコントロール
                    controlSection
                        .padding(.horizontal, ModernDesignSystem.Spacing.md)
                }
                .padding(.top, ModernDesignSystem.Spacing.lg)
            } else {
                emptyStateSection
                    .padding(.horizontal, ModernDesignSystem.Spacing.md)
                    .padding(.top, ModernDesignSystem.Spacing.xl)
            }
            
            Spacer()
        }
        .background(ModernDesignSystem.Colors.background)
        .onAppear {
            loadCards()
        }
        .sheet(isPresented: $showingModeSelection) {
            modeSelectionSheet
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Spacer()
            
            Button(action: {
                showingModeSelection = true
            }) {
                HStack(spacing: 4) {
                    Text(studyMode.description)
                        .font(ModernDesignSystem.Typography.body)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(ModernDesignSystem.Colors.accent)
                .padding(.horizontal, ModernDesignSystem.Spacing.sm)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                        .stroke(ModernDesignSystem.Colors.border, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("進捗")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                Text("\(currentCardIndex + 1) / \(cards.count)")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(ModernDesignSystem.Colors.text)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("暗記済み")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                Text("\(memorizedCount)")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(ModernDesignSystem.Colors.success)
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
    
    // MARK: - Card Section
    private var cardSection: some View {
        SimpleFlashCard(
            word: cards[currentCardIndex],
            showAnswer: showAnswer,
            audioPlayer: audioPlayer
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showAnswer.toggle()
            }
        }
        .frame(height: 300)
    }
    
    // MARK: - Control Section
    private var controlSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            // カード操作ボタン
            SimpleButton(
                title: showAnswer ? "問題に戻る" : "答えを見る",
                icon: showAnswer ? "arrow.clockwise" : "eye",
                style: .secondary
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAnswer.toggle()
                }
            }
            
            // 評価ボタン（答えが表示されている場合のみ）
            if showAnswer {
                HStack(spacing: ModernDesignSystem.Spacing.md) {
                    SimpleButton(
                        title: "もう一度",
                        icon: "arrow.counterclockwise",
                        style: .secondary
                    ) {
                        markAsNotMemorized()
                    }
                    
                    SimpleButton(
                        title: "覚えた",
                        icon: "checkmark",
                        style: .primary
                    ) {
                        markAsMemorized()
                    }
                }
            }
            
            // ナビゲーションボタン
            HStack(spacing: ModernDesignSystem.Spacing.md) {
                SimpleButton(
                    title: "前へ",
                    icon: "chevron.left",
                    style: .secondary
                ) {
                    previousCard()
                }
                .disabled(currentCardIndex == 0)
                
                SimpleButton(
                    title: "次へ",
                    icon: "chevron.right",
                    style: .secondary
                ) {
                    nextCard()
                }
                .disabled(currentCardIndex == cards.count - 1)
            }
        }
    }
    
    // MARK: - Empty State Section
    private var emptyStateSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 48))
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
            
            Text("学習するカードがありません")
                .font(ModernDesignSystem.Typography.title2)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            Text("他の学習モードを選択してください")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            SimpleButton(
                title: "学習モードを変更",
                icon: "slider.horizontal.3",
                style: .primary
            ) {
                showingModeSelection = true
            }
        }
        .padding(ModernDesignSystem.Spacing.lg)
        .background(Color.white)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
    
    // MARK: - Mode Selection Sheet
    private var modeSelectionSheet: some View {
        NavigationView {
            List(StudyMode.allCases, id: \.self) { mode in
                Button(action: {
                    studyMode = mode
                    showingModeSelection = false
                    loadCards()
                }) {
                    HStack {
                        Text(mode.description)
                            .foregroundColor(ModernDesignSystem.Colors.text)
                        Spacer()
                        if studyMode == mode {
                            Image(systemName: "checkmark")
                                .foregroundColor(ModernDesignSystem.Colors.accent)
                        }
                    }
                }
            }
            .navigationTitle("学習モード選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        showingModeSelection = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadCards() {
        switch studyMode {
        case .unstudiedOnly:
            cards = wordData.getUnstudiedWords()
        case .favorites:
            cards = wordData.words.filter { wordData.isFavorite(word: $0) }
        case .all:
            cards = wordData.words
        case .random:
            cards = Array(wordData.words.shuffled().prefix(50))
        }
        
        currentCardIndex = 0
        showAnswer = false
        memorizedCount = 0
    }
    
    private func nextCard() {
        if currentCardIndex < cards.count - 1 {
            currentCardIndex += 1
            showAnswer = false
        }
    }
    
    private func previousCard() {
        if currentCardIndex > 0 {
            currentCardIndex -= 1
            showAnswer = false
        }
    }
    
    private func markAsMemorized() {
        let currentWord = cards[currentCardIndex]
        wordData.markAsStudied(word: currentWord)
        memorizedCount += 1
        nextCard()
    }
    
    private func markAsNotMemorized() {
        nextCard()
    }
}

// MARK: - Simple Flash Card Component
struct SimpleFlashCard: View {
    let word: ChineseWord
    let showAnswer: Bool
    @ObservedObject var audioPlayer: AudioPlayerManager
    
    var body: some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            if !showAnswer {
                // 問題面
                VStack(spacing: ModernDesignSystem.Spacing.md) {
                    Text("この中国語の意味は？")
                        .font(ModernDesignSystem.Typography.headline)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    
                    Text(word.word)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(ModernDesignSystem.Colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text(word.pronunciation)
                        .font(ModernDesignSystem.Typography.title2)
                        .foregroundColor(ModernDesignSystem.Colors.accent)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        let csvNumber = Int(word.number) ?? 1
                        audioPlayer.playAudio(index: csvNumber)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.wave.2")
                            Text("音声を聞く")
                        }
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(ModernDesignSystem.Colors.accent)
                        .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        .padding(.vertical, ModernDesignSystem.Spacing.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                .stroke(ModernDesignSystem.Colors.accent, lineWidth: 1)
                        )
                    }
                }
            } else {
                // 答え面
                VStack(spacing: ModernDesignSystem.Spacing.md) {
                    Text("答え")
                        .font(ModernDesignSystem.Typography.headline)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    
                    Text(word.meaning)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(ModernDesignSystem.Colors.text)
                        .multilineTextAlignment(.center)
                    
                    if !word.example.isEmpty {
                        Divider()
                            .padding(.vertical, ModernDesignSystem.Spacing.sm)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("例文")
                                .font(ModernDesignSystem.Typography.headline)
                                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                            
                            Text(word.example)
                                .font(ModernDesignSystem.Typography.body)
                                .foregroundColor(ModernDesignSystem.Colors.text)
                            
                            Text(word.exampleMeaning)
                                .font(ModernDesignSystem.Typography.body)
                                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(ModernDesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 250)
        .background(Color.white)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.medium.color,
            radius: ModernDesignSystem.Shadow.medium.radius,
            x: ModernDesignSystem.Shadow.medium.x,
            y: ModernDesignSystem.Shadow.medium.y
        )
    }
}

#Preview {
    MemorizationView(wordData: ChineseWordData())
}