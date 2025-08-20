//
//  SpeechPracticeView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct SpeechPracticeView: View {
    @ObservedObject var wordData: ChineseWordData
    @StateObject private var speechManager = SpeechRecognitionManager()
    @StateObject private var audioPlayer = AudioPlayerManager()
    @StateObject private var studyDataManager = StudyDataManager.shared
    @Environment(\.themeColors) var themeColors
    
    @State private var currentWord: ChineseWord?
    @State private var practiceWords: [ChineseWord] = []
    @State private var currentIndex = 0
    @State private var showResult = false
    @State private var pronunciationResult: PronunciationResult?
    @State private var practiceMode: PracticeMode = .words
    @State private var score = 0
    @State private var totalAttempts = 0
    @State private var showingModeSelection = false
    @State private var practiceOrderMode: OrderMode = .number
    
    enum OrderMode: String, CaseIterable {
        case number = "番号順"
        case random = "ランダム"
        case difficulty = "難易度順"
        
        var description: String {
            return self.rawValue
        }
    }
    
    enum PracticeMode: String, CaseIterable {
        case words = "単語練習"
        case sentences = "例文練習"
        case favorites = "お気に入り"
        case unstudied = "未学習"
        
        var description: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // スクロール可能なコンテンツ
            ScrollView {
                VStack(spacing: ModernDesignSystem.Spacing.lg) {
                    // モード選択
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showingModeSelection = true
                        }) {
                            HStack(spacing: 4) {
                                Text(practiceMode.description)
                                    .font(ModernDesignSystem.Typography.body)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(themeColors.accent)
                            .padding(.horizontal, ModernDesignSystem.Spacing.sm)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                    .stroke(themeColors.border, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, ModernDesignSystem.Spacing.md)
                    
                    if speechManager.isAuthorized {
                        if let word = currentWord {
                            // 順番変更コントロール
                            wordOrderControlSection
                                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                            
                            // プレミアム進捗表示
                            if totalAttempts > 0 {
                                LuxuryCard(elevation: .low) {
                                    progressSection
                                }
                                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                            }
                            
                            // プレミアム練習コンテンツ
                            LuxuryCard(elevation: .medium) {
                                practiceContentSection(for: word)
                            }
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                            
                            // プレミアム音声認識セクション
                            LuxuryCard(elevation: .high) {
                                speechRecognitionSection
                            }
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                            
                            // 認識結果表示（録音中や認識後に表示）
                            if speechManager.isRecording || !speechManager.recognizedText.isEmpty {
                                LuxuryCard(elevation: .premium) {
                                    recognizedTextSection
                                }
                                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                            }
                        } else if practiceWords.isEmpty {
                            LuxuryCard(elevation: .medium) {
                                emptyStateSection
                            }
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        } else {
                            LuxuryCard(elevation: .low) {
                                loadingSection
                            }
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        }
                    } else {
                        LuxuryCard(elevation: .medium) {
                            authorizationSection
                        }
                        .padding(.horizontal, ModernDesignSystem.Spacing.md)
                    }
                }
                .padding(.top, ModernDesignSystem.Spacing.md)
                .padding(.bottom, ModernDesignSystem.Spacing.xxxl) // タブバーのための余白
            }
        }
        .background(themeColors.background)
        .onAppear {
            loadPracticeWords()
        }
        .sheet(isPresented: $showingModeSelection) {
            modeSelectionSheet
        }
        .sheet(isPresented: $showResult) {
            if let result = pronunciationResult {
                DetailedResultView(result: result) {
                    showResult = false
                    pronunciationResult = nil
                    speechManager.resetSession()
                } nextAction: {
                    nextWord()
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("音声練習")
                .font(ModernDesignSystem.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(themeColors.text)
            
            Spacer()
            
            Button(action: {
                showingModeSelection = true
            }) {
                HStack(spacing: 4) {
                    Text(practiceMode.description)
                        .font(ModernDesignSystem.Typography.body)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(themeColors.accent)
                .padding(.horizontal, ModernDesignSystem.Spacing.sm)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                        .stroke(themeColors.border, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("スコア")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(themeColors.textSecondary)
                Text("\(score)/\(totalAttempts)")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(themeColors.success)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("進捗")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(themeColors.textSecondary)
                Text("\(currentIndex + 1)/\(practiceWords.count)")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(themeColors.text)
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
    
    // MARK: - Practice Content Section
    private func practiceContentSection(for word: ChineseWord) -> some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            VStack(spacing: ModernDesignSystem.Spacing.md) {
                Text(practiceMode == .sentences ? "この例文を発音してください" : "この単語を発音してください")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(themeColors.textSecondary)
                
                Text(practiceMode == .sentences ? word.example : word.word)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeColors.text)
                    .multilineTextAlignment(.center)
                
                if practiceMode != .sentences {
                    Text(word.pronunciation)
                        .font(ModernDesignSystem.Typography.title2)
                        .foregroundColor(themeColors.accent)
                }
            }
            
            Button(action: {
                playModelAudio(for: word)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2")
                    Text("お手本を聞く")
                }
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ModernDesignSystem.Spacing.sm)
                .background(themeColors.accent)
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
            }
        }
        .padding(ModernDesignSystem.Spacing.lg)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
    
    // MARK: - Speech Recognition Section
    private var speechRecognitionSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            Button(action: {
                toggleRecording()
            }) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(speechManager.isRecording ? Color.red : themeColors.accent)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    Text(speechManager.isRecording ? "タップで録音終了" : "録音開始")
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(speechManager.isRecording ? .red : themeColors.text)
                }
            }
            
            if speechManager.confidence > 0 {
                VStack(spacing: 4) {
                    HStack {
                        Text("音声認識信頼度: \(Int(speechManager.confidence * 100))%")
                            .font(ModernDesignSystem.Typography.caption)
                            .foregroundColor(themeColors.textSecondary)
                        
                        Spacer()
                        
                        // 信頼度のレベル表示
                        Text(confidenceLevel)
                            .font(ModernDesignSystem.Typography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(confidenceColor)
                    }
                    
                    ProgressView(value: speechManager.confidence, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor))
                        .frame(height: 6)
                }
            }
            
            // 録音中に手動で停止して判定するボタン
            if speechManager.isRecording && !speechManager.recognizedText.isEmpty {
                SimpleButton(
                    title: "録音停止して判定",
                    icon: "checkmark.circle",
                    style: .secondary
                ) {
                    speechManager.stopRecording()
                    // 少し待ってから評価を実行
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        evaluatePronunciation()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private var recognizedTextSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            // 認識結果のヘッダー
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(themeColors.accent)
                Text("あなたの音声:")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(themeColors.text)
                Spacer()
            }
            
            // 認識されたテキストを大きく表示
            VStack(spacing: ModernDesignSystem.Spacing.sm) {
                Text("認識された文字")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(themeColors.textSecondary)
                
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.md)
                        .fill(speechManager.isRecording ? 
                              themeColors.surface.opacity(0.8) : 
                              themeColors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.md)
                                .stroke(speechManager.isRecording ? 
                                        themeColors.accent : 
                                        Color.clear, lineWidth: 2)
                        )
                    
                    // テキスト表示
                    if speechManager.recognizedText.isEmpty {
                        HStack(spacing: 8) {
                            if speechManager.isRecording {
                                // 録音中のアニメーション
                                HStack(spacing: 4) {
                                    ForEach(0..<3, id: \.self) { index in
                                        Circle()
                                            .fill(themeColors.accent)
                                            .frame(width: 8, height: 8)
                                            .scaleEffect(speechManager.isRecording ? 1.0 : 0.5)
                                            .animation(
                                                Animation.easeInOut(duration: 0.6)
                                                    .repeatForever()
                                                    .delay(Double(index) * 0.2),
                                                value: speechManager.isRecording
                                            )
                                    }
                                }
                                Text("音声を認識中...")
                                    .font(ModernDesignSystem.Typography.body)
                                    .foregroundColor(themeColors.accent)
                            } else {
                                Image(systemName: "mic.slash")
                                    .foregroundColor(themeColors.textSecondary)
                                Text("音声を録音してください...")
                                    .font(ModernDesignSystem.Typography.body)
                                    .foregroundColor(themeColors.textSecondary)
                            }
                        }
                    } else {
                        Text(speechManager.recognizedText)
                            .font(ModernDesignSystem.Typography.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(themeColors.text)
                            .multilineTextAlignment(.center)
                            .scaleEffect(speechManager.isRecording ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: speechManager.recognizedText)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding(ModernDesignSystem.Spacing.md)
            }
            
            // 目標テキストとの比較表示
            if let word = currentWord, !speechManager.recognizedText.isEmpty {
                let targetText = practiceMode == .sentences ? word.example : word.word
                
                VStack(spacing: ModernDesignSystem.Spacing.sm) {
                    Text("目標:")
                        .font(ModernDesignSystem.Typography.caption)
                        .foregroundColor(themeColors.textSecondary)
                    
                    Text(targetText)
                        .font(ModernDesignSystem.Typography.title3)
                        .fontWeight(.medium)
                        .foregroundColor(themeColors.accent)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(ModernDesignSystem.Spacing.sm)
                        .background(themeColors.cardBackground)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                .stroke(themeColors.accent, lineWidth: 1)
                        )
                }
            }
            
            // 評価ボタン
            if !speechManager.recognizedText.isEmpty {
                SimpleButton(
                    title: "発音を評価する",
                    icon: "checkmark.circle.fill",
                    style: .primary
                ) {
                    evaluatePronunciation()
                }
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.medium.color,
            radius: ModernDesignSystem.Shadow.medium.radius,
            x: ModernDesignSystem.Shadow.medium.x,
            y: ModernDesignSystem.Shadow.medium.y
        )
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            Image(systemName: "waveform.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(themeColors.textSecondary)
            
            Text("練習する単語がありません")
                .font(ModernDesignSystem.Typography.title2)
                .foregroundColor(themeColors.text)
            
            Text("別の練習モードを選択してください")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(themeColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(ModernDesignSystem.Spacing.lg)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
    
    private var loadingSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            ProgressView()
            Text("読み込み中...")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(themeColors.textSecondary)
        }
    }
    
    private var authorizationSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("音声認識の許可が必要です")
                .font(ModernDesignSystem.Typography.title2)
                .foregroundColor(themeColors.text)
            
            if let error = speechManager.authorizationError {
                Text(error)
                    .font(ModernDesignSystem.Typography.body)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Text("設定アプリから音声認識とマイクのアクセスを許可してください")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(themeColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(ModernDesignSystem.Spacing.lg)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
    
    private var modeSelectionSheet: some View {
        NavigationView {
            List(PracticeMode.allCases, id: \.self) { mode in
                Button(action: {
                    practiceMode = mode
                    showingModeSelection = false
                    loadPracticeWords()
                }) {
                    HStack {
                        Text(mode.description)
                            .foregroundColor(themeColors.text)
                        Spacer()
                        if practiceMode == mode {
                            Image(systemName: "checkmark")
                                .foregroundColor(themeColors.accent)
                        }
                    }
                }
            }
            .navigationTitle("練習モード選択")
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
    
    // MARK: - Computed Properties
    private var confidenceColor: Color {
        if speechManager.confidence >= 0.8 {
            return .green
        } else if speechManager.confidence >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var confidenceLevel: String {
        if speechManager.confidence >= 0.8 {
            return "高精度"
        } else if speechManager.confidence >= 0.5 {
            return "中精度"
        } else {
            return "低精度"
        }
    }
    
    // MARK: - Methods
    private func toggleRecording() {
        if speechManager.isRecording {
            speechManager.stopRecording()
        } else {
            // 新しい録音開始時に前の結果をクリア
            showResult = false
            pronunciationResult = nil
            speechManager.startRecording()
        }
    }
    
    private func playModelAudio(for word: ChineseWord) {
        let csvRowNumber = word.csvRowIndex
        if practiceMode == .sentences {
            audioPlayer.playExampleAudio(index: csvRowNumber)
        } else {
            audioPlayer.playAudio(index: csvRowNumber)
        }
    }
    
    private func evaluatePronunciation() {
        guard let word = currentWord else { return }
        
        let target = practiceMode == .sentences ? word.example : word.word
        let result = speechManager.evaluatePronunciation(
            original: target,
            recognized: speechManager.recognizedText
        )
        
        pronunciationResult = result
        
        if result.score >= 0.7 {
            score += 1
            wordData.markAsStudied(word: word)
        }
        
        totalAttempts += 1
        
        // StudyDataManagerの統計を更新
        studyDataManager.updateSpeechPracticeStats(accuracy: Float(result.score))
        
        showResult = true
    }
    
    private func nextWord() {
        if currentIndex < practiceWords.count - 1 {
            currentIndex += 1
            currentWord = practiceWords[currentIndex]
        } else {
            currentIndex = 0
            currentWord = practiceWords.first
        }
        
        // 音声認識を完全にリセット
        speechManager.resetSession()
        showResult = false
        pronunciationResult = nil
    }
    
    // MARK: - Word Order Control Section
    private var wordOrderControlSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            // 進捗とナビゲーション
            HStack(spacing: ModernDesignSystem.Spacing.md) {
                // 前の単語へ
                Button(action: { previousWord() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(currentIndex <= 0 ? themeColors.textSecondary : themeColors.accent)
                        .frame(width: 44, height: 44)
                        .background(themeColors.cardBackground)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                .stroke(themeColors.border, lineWidth: 1)
                        )
                }
                .disabled(currentIndex <= 0)
                
                Spacer()
                
                // 進捗表示
                VStack(spacing: 4) {
                    Text("\(currentIndex + 1) / \(practiceWords.count)")
                        .font(ModernDesignSystem.Typography.headline)
                        .foregroundColor(themeColors.text)
                    
                    ProgressView(value: Double(currentIndex + 1), total: Double(practiceWords.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: themeColors.accent))
                        .frame(height: 6)
                        .frame(width: 100)
                }
                
                Spacer()
                
                // 次の単語へ
                Button(action: { nextWord() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(currentIndex >= practiceWords.count - 1 ? themeColors.textSecondary : themeColors.accent)
                        .frame(width: 44, height: 44)
                        .background(themeColors.cardBackground)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                .stroke(themeColors.border, lineWidth: 1)
                        )
                }
                .disabled(currentIndex >= practiceWords.count - 1)
            }
            
            // 順番変更オプション（コンパクト）
            HStack(spacing: ModernDesignSystem.Spacing.xs) {
                ForEach(OrderMode.allCases, id: \.self) { mode in
                    Button(action: { changeOrderMode(mode) }) {
                        HStack(spacing: 4) {
                            Image(systemName: iconForOrderMode(mode))
                                .font(.system(size: 12, weight: .medium))
                            Text(mode.rawValue)
                                .font(ModernDesignSystem.Typography.caption)
                        }
                        .foregroundColor(practiceOrderMode == mode ? .white : themeColors.text)
                        .padding(.horizontal, ModernDesignSystem.Spacing.sm)
                        .padding(.vertical, ModernDesignSystem.Spacing.xs)
                        .background(practiceOrderMode == mode ? themeColors.accent : themeColors.cardBackground)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                .stroke(practiceOrderMode == mode ? Color.clear : themeColors.border, lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
                
                // シャッフルボタン
                Button(action: { shufflePracticeWords() }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeColors.accent)
                        .frame(width: 32, height: 32)
                        .background(themeColors.cardBackground)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                .stroke(themeColors.border, lineWidth: 1)
                        )
                }
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
    
    private func loadPracticeWords() {
        switch practiceMode {
        case .words:
            practiceWords = Array(wordData.words.prefix(20))
        case .sentences:
            practiceWords = Array(wordData.words.filter { !$0.example.isEmpty }.prefix(20))
        case .favorites:
            practiceWords = wordData.words.filter { wordData.isFavorite(word: $0) }
        case .unstudied:
            practiceWords = wordData.words.filter { !wordData.isStudied(word: $0) }
        }
        
        // 順序モードに従って並び替え
        applyCurrentOrderMode()
        
        currentIndex = 0
        currentWord = practiceWords.first
        score = 0
        totalAttempts = 0
    }
    
    // MARK: - Order Management Methods
    private func applyCurrentOrderMode() {
        switch practiceOrderMode {
        case .number:
            practiceWords.sort { Int($0.number) ?? 0 < Int($1.number) ?? 0 }
        case .random:
            practiceWords.shuffle()
        case .difficulty:
            // 未学習 → 学習済みの順、同じカテゴリ内では番号順
            practiceWords.sort { word1, word2 in
                let isStudied1 = wordData.isStudied(word: word1)
                let isStudied2 = wordData.isStudied(word: word2)
                
                if isStudied1 != isStudied2 {
                    return !isStudied1 && isStudied2 // 未学習を先に
                }
                
                return (Int(word1.number) ?? 0) < (Int(word2.number) ?? 0)
            }
        }
    }
    
    private func changeOrderMode(_ newMode: OrderMode) {
        practiceOrderMode = newMode
        applyCurrentOrderMode()
        currentIndex = 0
        currentWord = practiceWords.first
    }
    
    private func shufflePracticeWords() {
        practiceWords.shuffle()
        currentIndex = 0
        currentWord = practiceWords.first
    }
    
    private func previousWord() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        currentWord = practiceWords[currentIndex]
        // 音声認識を完全にリセット
        speechManager.resetSession()
        showResult = false
        pronunciationResult = nil
    }
    
    private func iconForOrderMode(_ mode: OrderMode) -> String {
        switch mode {
        case .number: return "123.rectangle"
        case .random: return "dice"
        case .difficulty: return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - Detailed Result View
struct DetailedResultView: View {
    let result: PronunciationResult
    let retryAction: () -> Void
    let nextAction: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ModernDesignSystem.Spacing.lg) {
                    // 全体スコア表示
                    overallScoreSection
                    
                    // 単語レベル分析
                    if !result.wordLevelResults.isEmpty {
                        wordLevelAnalysisSection
                    }
                    
                    // 詳細フィードバック
                    feedbackSection
                    
                    // アクションボタン
                    actionButtonsSection
                }
                .padding(ModernDesignSystem.Spacing.lg)
            }
            .background(themeColors.background)
            .navigationTitle("発音評価結果")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("完了") { dismiss() })
        }
    }
    
    private var overallScoreSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            // スコア円グラフ
            ZStack {
                Circle()
                    .stroke(themeColors.border.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: result.score)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(result.score * 100))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(themeColors.text)
                    Text("点")
                        .font(.caption)
                        .foregroundColor(themeColors.textSecondary)
                }
            }
            
            Text("\(result.grade.emoji) \(result.grade.description)")
                .font(ModernDesignSystem.Typography.titleMedium)
                .foregroundColor(scoreColor)
        }
        .padding(ModernDesignSystem.Spacing.lg)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.lg)
    }
    
    private var wordLevelAnalysisSection: some View {
        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
            HStack {
                Text("単語別分析")
                    .font(ModernDesignSystem.Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(themeColors.text)
                
                Spacer()
                
                Text("ELSA Speak風")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(themeColors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeColors.accent.opacity(0.1))
                    .cornerRadius(4)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(result.wordLevelResults.count, 3)), spacing: ModernDesignSystem.Spacing.sm) {
                ForEach(Array(result.wordLevelResults.enumerated()), id: \.offset) { index, wordResult in
                    WordResultCard(wordResult: wordResult)
                }
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.lg)
    }
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.sm) {
            Text("詳細フィードバック")
                .font(ModernDesignSystem.Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(themeColors.text)
            
            Text(result.feedback)
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(themeColors.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.cardBackground)
        .cornerRadius(ModernDesignSystem.CornerRadius.lg)
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: ModernDesignSystem.Spacing.md) {
            Button(action: {
                dismiss()
                retryAction()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("もう一度")
                }
                .font(ModernDesignSystem.Typography.bodyMedium)
                .foregroundColor(themeColors.text)
                .padding(.vertical, ModernDesignSystem.Spacing.sm)
                .frame(maxWidth: .infinity)
                .background(themeColors.cardBackground)
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                        .stroke(themeColors.border, lineWidth: 1)
                )
            }
            
            Button(action: {
                dismiss()
                nextAction()
            }) {
                HStack {
                    Text("次へ")
                    Image(systemName: "arrow.right")
                }
                .font(ModernDesignSystem.Typography.bodyMedium)
                .foregroundColor(.white)
                .padding(.vertical, ModernDesignSystem.Spacing.sm)
                .frame(maxWidth: .infinity)
                .background(themeColors.accent)
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
            }
        }
    }
    
    private var scoreColor: Color {
        switch result.grade {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .fair:
            return .orange
        case .needsImprovement:
            return .red
        }
    }
}

// MARK: - Word Result Card
struct WordResultCard: View {
    let wordResult: WordLevelResult
    @Environment(\.themeColors) var themeColors
    
    var body: some View {
        VStack(spacing: 4) {
            // 目標単語
            Text(wordResult.targetWord)
                .font(ModernDesignSystem.Typography.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(themeColors.text)
            
            // 認識された単語
            if !wordResult.word.isEmpty {
                Text(wordResult.word)
                    .font(ModernDesignSystem.Typography.bodyMedium)
                    .foregroundColor(wordColor)
            }
            
            // 類似度バー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(themeColors.border.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(wordColor)
                        .frame(width: geometry.size.width * CGFloat(wordResult.similarity), height: 4)
                }
            }
            .frame(height: 4)
            
            // フィードバック
            Text(wordResult.feedback)
                .font(ModernDesignSystem.Typography.caption)
                .foregroundColor(wordColor)
                .fontWeight(.medium)
        }
        .padding(ModernDesignSystem.Spacing.sm)
        .background(wordColor.opacity(0.1))
        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                .stroke(wordColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var wordColor: Color {
        if wordResult.isCorrect {
            return .green
        } else if wordResult.similarity >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    SpeechPracticeView(wordData: ChineseWordData())
}