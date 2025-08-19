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
    
    @State private var currentWord: ChineseWord?
    @State private var practiceWords: [ChineseWord] = []
    @State private var currentIndex = 0
    @State private var showResult = false
    @State private var pronunciationResult: PronunciationResult?
    @State private var practiceMode: PracticeMode = .words
    @State private var score = 0
    @State private var totalAttempts = 0
    @State private var showingModeSelection = false
    
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
            // シンプルなヘッダー
            headerSection
                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                .padding(.vertical, ModernDesignSystem.Spacing.md)
                .background(Color.white)
            
            Divider()
            
            if speechManager.isAuthorized {
                if let word = currentWord {
                    VStack(spacing: ModernDesignSystem.Spacing.lg) {
                        // シンプルな進捗表示
                        if totalAttempts > 0 {
                            progressSection
                                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        }
                        
                        // シンプルな練習コンテンツ
                        practiceContentSection(for: word)
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        
                        // 音声認識セクション
                        speechRecognitionSection
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        
                        // 認識結果表示（録音中や認識後に表示）
                        if speechManager.isRecording || !speechManager.recognizedText.isEmpty {
                            recognizedTextSection
                                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        }
                    }
                    .padding(.top, ModernDesignSystem.Spacing.lg)
                } else if practiceWords.isEmpty {
                    emptyStateSection
                        .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        .padding(.top, ModernDesignSystem.Spacing.xl)
                } else {
                    loadingSection
                        .padding(.top, ModernDesignSystem.Spacing.xl)
                }
            } else {
                authorizationSection
                    .padding(.horizontal, ModernDesignSystem.Spacing.md)
                    .padding(.top, ModernDesignSystem.Spacing.xl)
            }
            
            Spacer()
        }
        .background(ModernDesignSystem.Colors.background)
        .onAppear {
            loadPracticeWords()
        }
        .sheet(isPresented: $showingModeSelection) {
            modeSelectionSheet
        }
        .alert("結果", isPresented: $showResult) {
            Button("次へ") {
                nextWord()
            }
            Button("もう一度") {
                showResult = false
                speechManager.recognizedText = ""
            }
        } message: {
            if let result = pronunciationResult {
                Text("\(result.grade.emoji) \(result.feedback)\n\nスコア: \(Int(result.score * 100))%")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("音声練習")
                .font(ModernDesignSystem.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
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
                Text("スコア")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                Text("\(score)/\(totalAttempts)")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(ModernDesignSystem.Colors.success)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("進捗")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                Text("\(currentIndex + 1)/\(practiceWords.count)")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(ModernDesignSystem.Colors.text)
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
    
    // MARK: - Practice Content Section
    private func practiceContentSection(for word: ChineseWord) -> some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            VStack(spacing: ModernDesignSystem.Spacing.md) {
                Text(practiceMode == .sentences ? "この例文を発音してください" : "この単語を発音してください")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                
                Text(practiceMode == .sentences ? word.example : word.word)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ModernDesignSystem.Colors.text)
                    .multilineTextAlignment(.center)
                
                if practiceMode != .sentences {
                    Text(word.pronunciation)
                        .font(ModernDesignSystem.Typography.title2)
                        .foregroundColor(ModernDesignSystem.Colors.accent)
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
                .background(ModernDesignSystem.Colors.accent)
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
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
    
    // MARK: - Speech Recognition Section
    private var speechRecognitionSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            Button(action: {
                toggleRecording()
            }) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(speechManager.isRecording ? Color.red : ModernDesignSystem.Colors.accent)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    Text(speechManager.isRecording ? "タップで録音終了" : "録音開始")
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(speechManager.isRecording ? .red : ModernDesignSystem.Colors.text)
                }
            }
            
            if speechManager.confidence > 0 {
                VStack(spacing: 4) {
                    Text("認識信頼度: \(Int(speechManager.confidence * 100))%")
                        .font(ModernDesignSystem.Typography.caption)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    
                    ProgressView(value: speechManager.confidence, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor))
                        .frame(height: 4)
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
                    .foregroundColor(ModernDesignSystem.Colors.accent)
                Text("あなたの音声:")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(ModernDesignSystem.Colors.text)
                Spacer()
            }
            
            // 認識されたテキストを大きく表示
            VStack(spacing: ModernDesignSystem.Spacing.sm) {
                Text("認識された文字")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                
                Text(speechManager.recognizedText.isEmpty ? "音声を録音してください..." : speechManager.recognizedText)
                    .font(ModernDesignSystem.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(speechManager.recognizedText.isEmpty ? ModernDesignSystem.Colors.textSecondary : ModernDesignSystem.Colors.text)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .padding(ModernDesignSystem.Spacing.md)
                    .background(ModernDesignSystem.Colors.lightGray)
                    .cornerRadius(ModernDesignSystem.CornerRadius.md)
            }
            
            // 目標テキストとの比較表示
            if let word = currentWord, !speechManager.recognizedText.isEmpty {
                let targetText = practiceMode == .sentences ? word.example : word.word
                
                VStack(spacing: ModernDesignSystem.Spacing.sm) {
                    Text("目標:")
                        .font(ModernDesignSystem.Typography.caption)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    
                    Text(targetText)
                        .font(ModernDesignSystem.Typography.title3)
                        .fontWeight(.medium)
                        .foregroundColor(ModernDesignSystem.Colors.accent)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(ModernDesignSystem.Spacing.sm)
                        .background(Color.white)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                .stroke(ModernDesignSystem.Colors.accent, lineWidth: 1)
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
        .background(Color.white)
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
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
            
            Text("練習する単語がありません")
                .font(ModernDesignSystem.Typography.title2)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            Text("別の練習モードを選択してください")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
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
    
    private var loadingSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            ProgressView()
            Text("読み込み中...")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
        }
    }
    
    private var authorizationSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("音声認識の許可が必要です")
                .font(ModernDesignSystem.Typography.title2)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            if let error = speechManager.authorizationError {
                Text(error)
                    .font(ModernDesignSystem.Typography.body)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Text("設定アプリから音声認識とマイクのアクセスを許可してください")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
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
                            .foregroundColor(ModernDesignSystem.Colors.text)
                        Spacer()
                        if practiceMode == mode {
                            Image(systemName: "checkmark")
                                .foregroundColor(ModernDesignSystem.Colors.accent)
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
    
    // MARK: - Methods
    private func toggleRecording() {
        if speechManager.isRecording {
            speechManager.stopRecording()
        } else {
            speechManager.startRecording()
        }
    }
    
    private func playModelAudio(for word: ChineseWord) {
        let csvNumber = Int(word.number) ?? 1
        if practiceMode == .sentences {
            audioPlayer.playExampleAudio(index: csvNumber)
        } else {
            audioPlayer.playAudio(index: csvNumber)
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
        
        speechManager.recognizedText = ""
        showResult = false
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
        
        currentIndex = 0
        currentWord = practiceWords.first
        score = 0
        totalAttempts = 0
    }
}

#Preview {
    SpeechPracticeView(wordData: ChineseWordData())
}