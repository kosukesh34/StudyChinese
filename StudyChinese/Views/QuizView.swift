//
//  QuizView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct QuizView: View {
    @ObservedObject var wordData: ChineseWordData
    @StateObject private var studyDataManager = StudyDataManager.shared
    @Environment(\.themeColors) var themeColors
    @State private var currentQuizWord: ChineseWord?
    @State private var options: [String] = []
    @State private var correctAnswer: String = ""
    @State private var selectedAnswer: String = ""
    @State private var isCorrect: Bool = false
    @State private var score: Int = 0
    @State private var totalQuestions: Int = 0
    @State private var quizType: QuizType = .meaningToWord
    @State private var resultMessage: String = ""
    @State private var showAnswerFeedback: Bool = false
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    enum QuizType: String, CaseIterable {
        case meaningToWord = "意味→単語"
        case wordToMeaning = "単語→意味"
        case pronunciationToWord = "発音→単語"
        case exampleToMeaning = "例文→意味"
        
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
                .background(themeColors.cardBackground)
            
            Divider()
            
            ScrollView {
                if let currentWord = currentQuizWord {
                    VStack(spacing: ModernDesignSystem.Spacing.lg) {
                        // シンプルなスコア表示
                        if totalQuestions > 0 {
                            scoreSection
                                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        }
                        
                        // シンプルな問題表示
                        questionSection(for: currentWord)
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        
                        // 結果フィードバック
                        if showAnswerFeedback {
                            feedbackSection
                                .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        }
                        
                        // シンプルな選択肢
                        optionsSection
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        
                        // 次の問題ボタン（回答後に表示）
                        if selectedAnswer.isEmpty == false {
                            SimpleButton(
                                title: "次の問題",
                                icon: "arrow.right.circle",
                                style: .primary
                            ) {
                                nextQuestion()
                            }
                            .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        }
                    }
                    .padding(.top, ModernDesignSystem.Spacing.lg)
                    .padding(.bottom, ModernDesignSystem.Spacing.xxxl)
                } else {
                    startSection
                        .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        .padding(.top, ModernDesignSystem.Spacing.xl)
                        .padding(.bottom, ModernDesignSystem.Spacing.xxxl)
                }
            }
        }
        .background(themeColors.background)
        .onChange(of: currentQuizWord) { _, newWord in
            // 問題表示時に音声を自動再生（クイズタイプによって音声の種類を決定）
            if let word = newWord {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let csvRowNumber = word.csvRowIndex
                    
                    switch quizType {
                    case .wordToMeaning, .meaningToWord, .pronunciationToWord:
                        // 単語の音声を再生
                        audioPlayer.playAudio(index: csvRowNumber)
                    case .exampleToMeaning:
                        // 例文の音声を再生
                        audioPlayer.playExampleAudio(index: csvRowNumber)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Spacer()
            
            Picker("クイズタイプ", selection: $quizType) {
                ForEach(QuizType.allCases, id: \.self) { type in
                    Text(type.description).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(themeColors.accent)
            .onChange(of: quizType) { _, _ in
                resetQuiz()
            }
        }
    }
    
    // MARK: - Score Section
    private var scoreSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("スコア")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(themeColors.textSecondary)
                Text("\(score)/\(totalQuestions)")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(themeColors.success)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("正答率")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(themeColors.textSecondary)
                Text("\(totalQuestions > 0 ? Int((Double(score) / Double(totalQuestions)) * 100) : 0)%")
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
    
    // MARK: - Question Section
    private func questionSection(for word: ChineseWord) -> some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            VStack(spacing: ModernDesignSystem.Spacing.md) {
                Text(getQuestionText(for: word))
                    .font(ModernDesignSystem.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeColors.text)
                    .multilineTextAlignment(.center)
                
                // 拼音（発音）を表示（wordToMeaningとexampleToMeaningの場合のみ）
                if !word.pronunciation.isEmpty && (quizType == .wordToMeaning || quizType == .exampleToMeaning) {
                    Text("[\(word.pronunciation)]")
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(themeColors.accent)
                        .fontWeight(.medium)
                }
            }
            
            // 音声再生ボタン（常に表示）
            Button(action: {
                let csvRowNumber = word.csvRowIndex
                
                switch quizType {
                case .wordToMeaning, .meaningToWord, .pronunciationToWord:
                    // 単語の音声を再生
                    audioPlayer.playAudio(index: csvRowNumber)
                case .exampleToMeaning:
                    // 例文の音声を再生
                    audioPlayer.playExampleAudio(index: csvRowNumber)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2")
                    Text("音声を再生")
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
    
    // MARK: - Feedback Section
    private var feedbackSection: some View {
        guard let word = currentQuizWord else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(spacing: ModernDesignSystem.Spacing.md) {
                // 正解/不正解表示
                HStack {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isCorrect ? .green : .red)
                    
                    Text(isCorrect ? "正解！" : "不正解")
                        .font(ModernDesignSystem.Typography.headline)
                        .foregroundColor(isCorrect ? .green : .red)
                    
                    Spacer()
                }
                
                // 正解表示（不正解の場合）
                if !isCorrect {
                    HStack {
                        Text("正解: \(correctAnswer)")
                            .font(ModernDesignSystem.Typography.body)
                            .foregroundColor(themeColors.textSecondary)
                        Spacer()
                    }
                }
                
                Divider()
                
                // 単語詳細情報
                VStack(spacing: ModernDesignSystem.Spacing.sm) {
                    // 拼音表示
                    if !word.pronunciation.isEmpty {
                        HStack {
                            Text("拼音:")
                                .font(ModernDesignSystem.Typography.body)
                                .fontWeight(.bold)
                                .foregroundColor(themeColors.text)
                            Text("[\(word.pronunciation)]")
                                .font(ModernDesignSystem.Typography.body)
                                .foregroundColor(themeColors.accent)
                            Spacer()
                        }
                    }
                    
                    // 例文表示
                    if !word.example.isEmpty {
                        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                            HStack {
                                Text("例文:")
                                    .font(ModernDesignSystem.Typography.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeColors.text)
                                Spacer()
                            }
                            
                            Text(word.example)
                                .font(ModernDesignSystem.Typography.body)
                                .foregroundColor(themeColors.text)
                                .multilineTextAlignment(.leading)
                            
                            // 例文の拼音表示
                            if !word.examplePronunciation.isEmpty {
                                Text("[\(word.examplePronunciation)]")
                                    .font(ModernDesignSystem.Typography.caption)
                                    .foregroundColor(themeColors.accent)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            if !word.exampleMeaning.isEmpty {
                                Text(word.exampleMeaning)
                                    .font(ModernDesignSystem.Typography.caption)
                                    .foregroundColor(themeColors.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    
                    // 例文音声ボタン
                    if !word.example.isEmpty {
                        Button(action: {
                            let csvRowNumber = word.csvRowIndex
                            audioPlayer.playExampleAudio(index: csvRowNumber)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.wave.2")
                                Text("例文音声を再生")
                            }
                            .font(ModernDesignSystem.Typography.body)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ModernDesignSystem.Spacing.sm)
                            .background(themeColors.accent)
                            .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                        }
                    }
                }
            }
            .padding(ModernDesignSystem.Spacing.md)
            .background(isCorrect ? themeColors.success.opacity(0.1) : themeColors.error.opacity(0.1))
            .cornerRadius(ModernDesignSystem.CornerRadius.md)
        )
    }
    
    // MARK: - Options Section
    private var optionsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: ModernDesignSystem.Spacing.md) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selectAnswer(option)
                }) {
                    Text(option)
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(getOptionTextColor(option))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .padding(ModernDesignSystem.Spacing.sm)
                        .background(getOptionBackgroundColor(option))
                        .cornerRadius(ModernDesignSystem.CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.md)
                                .stroke(getOptionBorderColor(option), lineWidth: 2)
                        )
                        .shadow(
                            color: ModernDesignSystem.Shadow.subtle.color,
                            radius: ModernDesignSystem.Shadow.subtle.radius,
                            x: ModernDesignSystem.Shadow.subtle.x,
                            y: ModernDesignSystem.Shadow.subtle.y
                        )
                }
                .disabled(selectedAnswer.isEmpty == false)
            }
        }
    }
    
    // MARK: - Start Section
    private var startSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 48))
                .foregroundColor(themeColors.accent)
            
            Text("クイズを始めましょう")
                .font(ModernDesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(themeColors.text)
            
            Text("上部でクイズタイプを選択して、クイズを開始してください")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(themeColors.textSecondary)
                .multilineTextAlignment(.center)
            
            SimpleButton(
                title: "クイズ開始",
                icon: "play.circle",
                style: .primary
            ) {
                startQuiz()
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
    
    // MARK: - Helper Methods
    private func getOptionTextColor(_ option: String) -> Color {
        if selectedAnswer.isEmpty {
            return themeColors.text
        }
        
        if option == correctAnswer {
            return .white
        } else if option == selectedAnswer && option != correctAnswer {
            return .white
        } else {
            return themeColors.text
        }
    }
    
    private func getOptionBackgroundColor(_ option: String) -> Color {
        if selectedAnswer.isEmpty {
            return themeColors.cardBackground
        }
        
        if option == correctAnswer {
            return .green
        } else if option == selectedAnswer && option != correctAnswer {
            return .red
        } else {
            return themeColors.cardBackground
        }
    }
    
    private func getOptionBorderColor(_ option: String) -> Color {
        if selectedAnswer.isEmpty {
            return themeColors.border
        }
        
        if option == correctAnswer {
            return .green
        } else if option == selectedAnswer && option != correctAnswer {
            return .red
        } else {
            return themeColors.border
        }
    }
    
    // MARK: - Methods
    private func startQuiz() {
        score = 0
        totalQuestions = 0
        generateQuestion()
    }
    
    private func resetQuiz() {
        currentQuizWord = nil
        selectedAnswer = ""
        showAnswerFeedback = false
        score = 0
        totalQuestions = 0
    }
    
    private func generateQuestion() {
        guard !wordData.words.isEmpty else { return }
        
        let randomWord = wordData.words.randomElement()!
        currentQuizWord = randomWord
        selectedAnswer = ""
        showAnswerFeedback = false
        
        switch quizType {
        case .meaningToWord:
            correctAnswer = randomWord.word
            options = generateOptions(correct: randomWord.word, type: .word)
        case .wordToMeaning:
            correctAnswer = randomWord.meaning
            options = generateOptions(correct: randomWord.meaning, type: .meaning)
        case .pronunciationToWord:
            correctAnswer = randomWord.word
            options = generateOptions(correct: randomWord.word, type: .word)
        case .exampleToMeaning:
            correctAnswer = randomWord.exampleMeaning
            options = generateOptions(correct: randomWord.exampleMeaning, type: .exampleMeaning)
        }
        
        // 正答を確実に保持してからシャッフル
        options.shuffle()
    }
    
    private func generateOptions(correct: String, type: OptionType) -> [String] {
        var allOptions: [String] = []
        
        switch type {
        case .word:
            allOptions = wordData.words.map { $0.word }
        case .meaning:
            allOptions = wordData.words.map { $0.meaning }
        case .exampleMeaning:
            allOptions = wordData.words.compactMap { word in
                word.exampleMeaning.isEmpty ? nil : word.exampleMeaning
            }
        }
        
        allOptions = allOptions.filter { $0 != correct }
        let incorrectOptions = Array(allOptions.shuffled().prefix(3))
        
        return [correct] + incorrectOptions
    }
    
    private func getQuestionText(for word: ChineseWord) -> String {
        switch quizType {
        case .meaningToWord:
            return "次の日本語の意味に対応する中国語は？\n\n\(word.meaning)"
        case .wordToMeaning:
            return "この中国語の意味は？（音声も確認してください）\n\n\(word.word)"
        case .pronunciationToWord:
            return "この拼音（発音）に対応する中国語は？\n\n\(word.pronunciation)"
        case .exampleToMeaning:
            return "この例文の意味は？（音声も確認してください）\n\n\(word.example)"
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrect = answer == correctAnswer
        
        if isCorrect {
            score += 1
            if let word = currentQuizWord {
                wordData.markAsStudied(word: word)
            }
        }
        
        totalQuestions += 1
        
        // StudyDataManagerの統計を更新
        let quizTypeName = String(describing: quizType)
        studyDataManager.updateQuizStats(correct: isCorrect, quizTypeName: quizTypeName)
        
        // フィードバックを表示
        withAnimation(.easeInOut(duration: 0.3)) {
            showAnswerFeedback = true
        }
    }
    
    private func nextQuestion() {
        generateQuestion()
    }
    
    enum OptionType {
        case word, meaning, exampleMeaning
    }
}

#Preview {
    QuizView(wordData: ChineseWordData())
}