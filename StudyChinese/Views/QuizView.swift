//
//  QuizView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct QuizView: View {
    @ObservedObject var wordData: ChineseWordData
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
                .background(Color.white)
            
            Divider()
            
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
            } else {
                startSection
                    .padding(.horizontal, ModernDesignSystem.Spacing.md)
                    .padding(.top, ModernDesignSystem.Spacing.xl)
            }
            
            Spacer()
        }
        .background(ModernDesignSystem.Colors.background)
        .onChange(of: currentQuizWord) { _, newWord in
            // 問題表示時に音声を自動再生
            if let word = newWord {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // CSVの番号をそのまま使用（AudioPlayerManagerで-1の調整済み）
                    let csvNumber = Int(word.number) ?? 1
                    audioPlayer.playAudio(index: csvNumber)
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
            .accentColor(ModernDesignSystem.Colors.accent)
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
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                Text("\(score)/\(totalQuestions)")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(ModernDesignSystem.Colors.success)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("正答率")
                    .font(ModernDesignSystem.Typography.caption)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                Text("\(totalQuestions > 0 ? Int((Double(score) / Double(totalQuestions)) * 100) : 0)%")
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
    
    // MARK: - Question Section
    private func questionSection(for word: ChineseWord) -> some View {
        VStack(spacing: ModernDesignSystem.Spacing.lg) {
            VStack(spacing: ModernDesignSystem.Spacing.md) {
                Text(getQuestionText(for: word))
                    .font(ModernDesignSystem.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(ModernDesignSystem.Colors.text)
                    .multilineTextAlignment(.center)
                
                // 拼音（発音）を表示
                if !word.pronunciation.isEmpty && (quizType == .wordToMeaning || quizType == .meaningToWord) {
                    Text("[\(word.pronunciation)]")
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(ModernDesignSystem.Colors.accent)
                        .fontWeight(.medium)
                }
            }
            
            // 音声再生ボタン（常に表示）
            Button(action: {
                // CSVの番号をそのまま使用（AudioPlayerManagerで-1の調整済み）
                let csvNumber = Int(word.number) ?? 1
                audioPlayer.playAudio(index: csvNumber)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2")
                    Text("音声を再生")
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
    
    // MARK: - Feedback Section
    private var feedbackSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "正解！" : "不正解")
                    .font(ModernDesignSystem.Typography.headline)
                    .foregroundColor(isCorrect ? .green : .red)
                
                Spacer()
            }
            
            if !isCorrect {
                HStack {
                    Text("正解: \(correctAnswer)")
                        .font(ModernDesignSystem.Typography.body)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    Spacer()
                }
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
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
                .foregroundColor(ModernDesignSystem.Colors.accent)
            
            Text("クイズを始めましょう")
                .font(ModernDesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(ModernDesignSystem.Colors.text)
            
            Text("上部でクイズタイプを選択して、クイズを開始してください")
                .font(ModernDesignSystem.Typography.body)
                .foregroundColor(ModernDesignSystem.Colors.textSecondary)
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
        .background(Color.white)
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
            return ModernDesignSystem.Colors.text
        }
        
        if option == correctAnswer {
            return .white
        } else if option == selectedAnswer && option != correctAnswer {
            return .white
        } else {
            return ModernDesignSystem.Colors.text
        }
    }
    
    private func getOptionBackgroundColor(_ option: String) -> Color {
        if selectedAnswer.isEmpty {
            return Color.white
        }
        
        if option == correctAnswer {
            return .green
        } else if option == selectedAnswer && option != correctAnswer {
            return .red
        } else {
            return Color.white
        }
    }
    
    private func getOptionBorderColor(_ option: String) -> Color {
        if selectedAnswer.isEmpty {
            return ModernDesignSystem.Colors.border
        }
        
        if option == correctAnswer {
            return .green
        } else if option == selectedAnswer && option != correctAnswer {
            return .red
        } else {
            return ModernDesignSystem.Colors.border
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
            return "この意味の中国語は？\n\n\(word.meaning)"
        case .wordToMeaning:
            return "この中国語の意味は？\n\n\(word.word)"
        case .pronunciationToWord:
            return "この発音の中国語は？\n\n\(word.pronunciation)"
        case .exampleToMeaning:
            return "この例文の意味は？\n\n\(word.example)"
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