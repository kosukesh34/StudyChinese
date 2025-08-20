//
//  LongTextDetailView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/21/25.
//

import SwiftUI

// 長文詳細表示・学習ビュー
struct LongTextDetailView: View {
    let longText: ChineseLongText
    @StateObject private var audioPlayer = AudioPlayerManager()
    @Environment(\.themeColors) var themeColors
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var showPinyin = true
    @State private var showTranslation = false
    @State private var fontSize: CGFloat = 16
    @State private var selectedSentence: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // ナビゲーションヘッダー
            navigationHeader
            
            // タブビュー
            VStack(spacing: 0) {
                // タブセレクタ
                tabSelector
                
                // タブコンテンツ
                TabView(selection: $selectedTab) {
                    // 本文タブ
                    textContentView
                        .tag(0)
                    
                    // 重要語タブ
                    keyWordsView
                        .tag(1)
                    
                    // 文法タブ
                    grammarView
                        .tag(2)
                    
                    // 練習問題タブ
                    exerciseView
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .background(themeColors.background)
        .navigationBarHidden(true)
    }
    
    private var navigationHeader: some View {
        VStack(spacing: ModernDesignSystem.Spacing.sm) {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    HStack(spacing: ModernDesignSystem.Spacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("戻る")
                            .font(ModernDesignSystem.Typography.bodyMedium)
                    }
                    .foregroundColor(themeColors.accent)
                }
                
                Spacer()
                
                // 音声再生ボタン
                Button(action: playLongTextAudio) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(themeColors.accent)
                }
                
                // 設定ボタン
                Menu {
                    Button(action: { showPinyin.toggle() }) {
                        HStack {
                            Text("拼音表示")
                            if showPinyin {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button(action: { showTranslation.toggle() }) {
                        HStack {
                            Text("翻訳表示")
                            if showTranslation {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button(action: { fontSize = max(12, fontSize - 2) }) {
                        Text("文字を小さく")
                    }
                    
                    Button(action: { fontSize = min(24, fontSize + 2) }) {
                        Text("文字を大きく")
                    }
                } label: {
                    Image(systemName: "textformat")
                        .font(.system(size: 20))
                        .foregroundColor(themeColors.textSecondary)
                }
            }
            
            // タイトル
            VStack(spacing: ModernDesignSystem.Spacing.xs) {
                Text(longText.title)
                    .font(ModernDesignSystem.Typography.headlineMedium)
                    .fontWeight(.bold)
                    .foregroundColor(themeColors.text)
                
                HStack(spacing: ModernDesignSystem.Spacing.sm) {
                    Text(longText.category.displayName)
                        .font(ModernDesignSystem.Typography.labelSmall)
                        .padding(.horizontal, ModernDesignSystem.Spacing.sm)
                        .padding(.vertical, ModernDesignSystem.Spacing.xs)
                        .background(themeColors.accent.opacity(0.1))
                        .foregroundColor(themeColors.accent)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                    
                    Text(longText.level.displayName)
                        .font(ModernDesignSystem.Typography.labelSmall)
                        .padding(.horizontal, ModernDesignSystem.Spacing.sm)
                        .padding(.vertical, ModernDesignSystem.Spacing.xs)
                        .background(getDifficultyColor(longText.level).opacity(0.1))
                        .foregroundColor(getDifficultyColor(longText.level))
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                }
            }
        }
        .padding(.horizontal, ModernDesignSystem.Spacing.md)
        .padding(.bottom, ModernDesignSystem.Spacing.md)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: ModernDesignSystem.Spacing.xs) {
                        Text(getTabTitle(index))
                            .font(ModernDesignSystem.Typography.labelMedium)
                            .fontWeight(selectedTab == index ? .semibold : .medium)
                        
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
    
    private var textContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.lg) {
                // 中国語本文
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
                    Text("中国語")
                        .font(ModernDesignSystem.Typography.headlineSmall)
                        .fontWeight(.semibold)
                        .foregroundColor(themeColors.text)
                    
                    if showPinyin {
                        ChineseTextWithPinyinView(
                            chineseText: longText.chineseText,
                            pinyinText: longText.pinyinText,
                            fontSize: fontSize,
                            chineseColor: themeColors.text,
                            pinyinColor: themeColors.accent
                        )
                    } else {
                        Text(longText.chineseText)
                            .font(.system(size: fontSize))
                            .foregroundColor(themeColors.text)
                            .lineSpacing(6)
                            .textSelection(.enabled)
                    }
                }
                .padding(ModernDesignSystem.Spacing.md)
                .background(themeColors.surface)
                .cornerRadius(ModernDesignSystem.CornerRadius.md)
                
                // 日本語翻訳
                if showTranslation {
                    VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
                        Text("日本語翻訳")
                            .font(ModernDesignSystem.Typography.headlineSmall)
                            .fontWeight(.semibold)
                            .foregroundColor(themeColors.text)
                        
                        Text(longText.japaneseTranslation)
                            .font(.system(size: fontSize))
                            .foregroundColor(themeColors.textSecondary)
                            .lineSpacing(6)
                    }
                    .padding(ModernDesignSystem.Spacing.md)
                    .background(themeColors.surface)
                    .cornerRadius(ModernDesignSystem.CornerRadius.md)
                }
            }
            .padding(ModernDesignSystem.Spacing.md)
        }
    }
    
    private var keyWordsView: some View {
        ScrollView {
            LazyVStack(spacing: ModernDesignSystem.Spacing.md) {
                ForEach(longText.keyWords) { keyWord in
                    KeyWordCardView(keyWord: keyWord)
                }
            }
            .padding(ModernDesignSystem.Spacing.md)
        }
    }
    
    private var grammarView: some View {
        ScrollView {
            LazyVStack(spacing: ModernDesignSystem.Spacing.md) {
                ForEach(longText.grammarPoints) { grammarPoint in
                    GrammarPointCardView(grammarPoint: grammarPoint)
                }
            }
            .padding(ModernDesignSystem.Spacing.md)
        }
    }
    
    private var exerciseView: some View {
        ScrollView {
            LazyVStack(spacing: ModernDesignSystem.Spacing.md) {
                ForEach(longText.exerciseQuestions) { question in
                    ExerciseQuestionCardView(question: question)
                }
            }
            .padding(ModernDesignSystem.Spacing.md)
        }
    }
    
    private func getTabTitle(_ index: Int) -> String {
        switch index {
        case 0: return "本文"
        case 1: return "重要語"
        case 2: return "文法"
        case 3: return "練習"
        default: return ""
        }
    }
    
    private func getDifficultyColor(_ level: DifficultyLevel) -> Color {
        switch level.color {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
    
    private func playLongTextAudio() {
        if audioPlayer.isPlaying {
            audioPlayer.stopAudio()
        } else {
            // 長文音声の再生（実装は後で調整）
            if let audioFileName = longText.audioFileName {
                audioPlayer.playLongTextAudio(fileName: audioFileName)
            }
        }
    }
}

// 中国語文字と拼音を組み合わせて表示するビュー
struct ChineseTextWithPinyinView: View {
    let chineseText: String
    let pinyinText: String
    let fontSize: CGFloat
    let chineseColor: Color
    let pinyinColor: Color
    
    var body: some View {
        let textSentences = splitIntoSentences()
        
        VStack(alignment: .leading, spacing: 12) {
            ForEach(0..<textSentences.count, id: \.self) { sentenceIndex in
                let sentence = textSentences[sentenceIndex]
                
                // 各文を自然に折り返し表示
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<splitSentenceIntoLines(sentence).count, id: \.self) { lineIndex in
                        let line = splitSentenceIntoLines(sentence)[lineIndex]
                        
                        // 拼音行と漢字行を分けて表示
                        VStack(spacing: 2) {
                            // 拼音行
                            HStack(spacing: 2) {
                                ForEach(0..<line.count, id: \.self) { charIndex in
                                    let pair = line[charIndex]
                                    Text(pair.pinyin)
                                        .font(.system(size: fontSize * 0.6))
                                        .foregroundColor(pinyinColor)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                        .frame(width: calculateCharWidth(pair.chinese), height: fontSize * 0.6)
                                        .onTapGesture {
                                            print("拼音: \(pair.pinyin), 文字: \(pair.chinese)")
                                        }
                                }
                                Spacer(minLength: 0)
                            }
                            
                            // 漢字行
                            HStack(spacing: 2) {
                                ForEach(0..<line.count, id: \.self) { charIndex in
                                    let pair = line[charIndex]
                                    Text(pair.chinese)
                                        .font(.system(size: fontSize))
                                        .foregroundColor(chineseColor)
                                        .lineLimit(1)
                                        .frame(width: calculateCharWidth(pair.chinese), height: fontSize)
                                        .onTapGesture {
                                            print("文字: \(pair.chinese), 拼音: \(pair.pinyin)")
                                        }
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .textSelection(.enabled)
    }
    
    private func splitSentenceIntoLines(_ sentence: [(chinese: String, pinyin: String)]) -> [[(chinese: String, pinyin: String)]] {
        let maxWidth = UIScreen.main.bounds.width - 80 // パディングを考慮
        var lines: [[(chinese: String, pinyin: String)]] = []
        var currentLine: [(chinese: String, pinyin: String)] = []
        var currentWidth: CGFloat = 0
        
        for pair in sentence {
            let charWidth = calculateCharWidth(pair.chinese) + 2 // スペース分を追加
            
            if currentWidth + charWidth > maxWidth && !currentLine.isEmpty {
                // 行が一杯になったら新しい行を開始
                lines.append(currentLine)
                currentLine = [pair]
                currentWidth = charWidth
            } else {
                // 現在の行に追加
                currentLine.append(pair)
                currentWidth += charWidth
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines
    }
    

    
    private func splitIntoSentences() -> [[(chinese: String, pinyin: String)]] {
        let pairs = parseChinesePinyinPairs()
        var sentences: [[(chinese: String, pinyin: String)]] = []
        var currentSentence: [(chinese: String, pinyin: String)] = []
        
        for pair in pairs {
            currentSentence.append(pair)
            
            // 句読点で文を区切る
            if ["。", "！", "？", ".", "!", "?"].contains(pair.chinese) {
                if !currentSentence.isEmpty {
                    sentences.append(currentSentence)
                    currentSentence = []
                }
            }
        }
        
        // 最後の文が句読点で終わらない場合
        if !currentSentence.isEmpty {
            sentences.append(currentSentence)
        }
        
        return sentences
    }
    
    private func parseChinesePinyinPairs() -> [(chinese: String, pinyin: String)] {
        let chineseChars = Array(chineseText)
        
        // 拼音テキストから句読点を除去して単語のみを取得
        let cleanPinyinText = pinyinText.replacingOccurrences(of: "[,.!?;:()（）「」『』…—－～~]", with: "", options: .regularExpression)
        let pinyinWords = cleanPinyinText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        var pairs: [(chinese: String, pinyin: String)] = []
        var pinyinIndex = 0
        
        for char in chineseChars {
            let charString = String(char)
            
            if charString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // 空白文字の場合、スキップ
                continue
            } else if isChineseCharacter(charString) {
                // 中国語文字の場合、対応する拼音を取得
                if pinyinIndex < pinyinWords.count {
                    let pinyin = pinyinWords[pinyinIndex]
                    pairs.append((chinese: charString, pinyin: pinyin))
                    pinyinIndex += 1
                } else {
                    // 拼音が不足している場合
                    pairs.append((chinese: charString, pinyin: ""))
                }
            } else if isPunctuation(charString) {
                // 句読点の場合、拼音なしで追加
                pairs.append((chinese: charString, pinyin: ""))
            } else {
                // その他の文字（英数字など）の場合
                pairs.append((chinese: charString, pinyin: ""))
            }
        }
        
        return pairs
    }
    
    private func isPunctuation(_ char: String) -> Bool {
        let punctuationMarks = ["。", "！", "？", ".", "!", "?", "，", "、", "；", "：", ",", ";", ":", "（", "）", "(", ")", "「", "」", "『", "』", "…", "—", "－", "～", "~"]
        return punctuationMarks.contains(char)
    }
    
    private func isChineseCharacter(_ char: String) -> Bool {
        guard let scalar = char.unicodeScalars.first else { return false }
        return (0x4e00...0x9fff).contains(scalar.value) // 基本的な漢字の範囲
    }
    
    private func calculateCharWidth(_ char: String) -> CGFloat {
        if isChineseCharacter(char) {
            return fontSize * 1.2 // 漢字は固定幅
        } else if isPunctuation(char) {
            return fontSize * 0.6 // 句読点は狭い
        } else {
            return fontSize * 0.8 // その他の文字
        }
    }
}

// 選択可能なテキストビュー（現在は使用していませんが、将来のために残しておきます）
struct SelectableTextView: UIViewRepresentable {
    let text: String
    let fontSize: CGFloat
    let textColor: Color
    let onTextSelected: (String) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.text = text
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor(textColor)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.font = UIFont.systemFont(ofSize: fontSize)
        uiView.text = text
        uiView.textColor = UIColor(textColor)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: SelectableTextView
        
        init(_ parent: SelectableTextView) {
            self.parent = parent
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            if let selectedRange = textView.selectedTextRange,
               let selectedText = textView.text(in: selectedRange), !selectedText.isEmpty {
                parent.onTextSelected(selectedText)
            }
        }
    }
}

// 重要語カードビュー
struct KeyWordCardView: View {
    let keyWord: ChineseLongText.KeyWord
    @Environment(\.themeColors) var themeColors
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                    Text(keyWord.word)
                        .font(ModernDesignSystem.Typography.headlineSmall)
                        .fontWeight(.semibold)
                        .foregroundColor(themeColors.text)
                    
                    Text(keyWord.pinyin)
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .foregroundColor(themeColors.accent)
                }
                
                Spacer()
                
                Button(action: {
                    // 単語音声再生（実装予定）
                }) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 20))
                        .foregroundColor(themeColors.accent)
                }
            }
            
            Text(keyWord.meaning)
                .font(ModernDesignSystem.Typography.bodyMedium)
                .foregroundColor(themeColors.textSecondary)
            
            if !keyWord.contextSentence.isEmpty {
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                    Text("例文")
                        .font(ModernDesignSystem.Typography.labelMedium)
                        .fontWeight(.medium)
                        .foregroundColor(themeColors.text)
                    
                    Text(keyWord.contextSentence)
                        .font(ModernDesignSystem.Typography.bodySmall)
                        .foregroundColor(themeColors.textSecondary)
                        .padding(ModernDesignSystem.Spacing.sm)
                        .background(themeColors.background)
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                }
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.surface)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
    }
}

// 文法ポイントカードビュー
struct GrammarPointCardView: View {
    let grammarPoint: ChineseLongText.GrammarPoint
    @Environment(\.themeColors) var themeColors
    @State private var showExamples = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
            HStack {
                Text(grammarPoint.point)
                    .font(ModernDesignSystem.Typography.headlineSmall)
                    .fontWeight(.semibold)
                    .foregroundColor(themeColors.text)
                
                Spacer()
                
                Button(action: { showExamples.toggle() }) {
                    Image(systemName: showExamples ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16))
                        .foregroundColor(themeColors.textSecondary)
                }
            }
            
            Text(grammarPoint.explanation)
                .font(ModernDesignSystem.Typography.bodyMedium)
                .foregroundColor(themeColors.textSecondary)
                .lineSpacing(4)
            
            if showExamples && !grammarPoint.examples.isEmpty {
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.sm) {
                    Text("例文")
                        .font(ModernDesignSystem.Typography.labelMedium)
                        .fontWeight(.medium)
                        .foregroundColor(themeColors.text)
                    
                    ForEach(grammarPoint.examples, id: \.self) { example in
                        Text("• \(example)")
                            .font(ModernDesignSystem.Typography.bodySmall)
                            .foregroundColor(themeColors.textSecondary)
                            .padding(.leading, ModernDesignSystem.Spacing.sm)
                    }
                }
                .padding(ModernDesignSystem.Spacing.sm)
                .background(themeColors.background)
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.surface)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .animation(.easeInOut(duration: 0.3), value: showExamples)
    }
}

// 練習問題カードビュー
struct ExerciseQuestionCardView: View {
    let question: ChineseLongText.ExerciseQuestion
    @Environment(\.themeColors) var themeColors
    @State private var selectedAnswer: String? = nil
    @State private var showAnswer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.md) {
            Text(question.question)
                .font(ModernDesignSystem.Typography.bodyMedium)
                .fontWeight(.medium)
                .foregroundColor(themeColors.text)
            
            if let options = question.options {
                VStack(spacing: ModernDesignSystem.Spacing.sm) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedAnswer = option
                            showAnswer = true
                        }) {
                            HStack {
                                Text(option)
                                    .font(ModernDesignSystem.Typography.bodyMedium)
                                    .foregroundColor(themeColors.text)
                                
                                Spacer()
                                
                                if showAnswer {
                                    Image(systemName: option == question.correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(option == question.correctAnswer ? .green : .red)
                                }
                            }
                            .padding(ModernDesignSystem.Spacing.md)
                            .background(getOptionBackgroundColor(option: option))
                            .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: ModernDesignSystem.CornerRadius.sm)
                                    .stroke(getOptionBorderColor(option: option), lineWidth: 1)
                            )
                        }
                        .disabled(showAnswer)
                    }
                }
            } else {
                Button(action: { showAnswer.toggle() }) {
                    Text(showAnswer ? "答えを隠す" : "答えを表示")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .foregroundColor(themeColors.accent)
                        .padding(ModernDesignSystem.Spacing.md)
                        .background(themeColors.accent.opacity(0.1))
                        .cornerRadius(ModernDesignSystem.CornerRadius.sm)
                }
            }
            
            if showAnswer {
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.sm) {
                    Text("正答: \(question.correctAnswer)")
                        .font(ModernDesignSystem.Typography.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    Text(question.explanation)
                        .font(ModernDesignSystem.Typography.bodySmall)
                        .foregroundColor(themeColors.textSecondary)
                }
                .padding(ModernDesignSystem.Spacing.md)
                .background(Color.green.opacity(0.1))
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(themeColors.surface)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
    }
    
    private func getOptionBackgroundColor(option: String) -> Color {
        if showAnswer {
            if option == question.correctAnswer {
                return Color.green.opacity(0.1)
            } else if option == selectedAnswer {
                return Color.red.opacity(0.1)
            } else {
                return themeColors.background
            }
        } else {
            return themeColors.background
        }
    }
    
    private func getOptionBorderColor(option: String) -> Color {
        if showAnswer {
            if option == question.correctAnswer {
                return Color.green
            } else if option == selectedAnswer {
                return Color.red
            } else {
                return themeColors.border
            }
        } else {
            return themeColors.border
        }
    }
}



#Preview {
    LongTextDetailView(longText: ChineseLongTextData().longTexts.first!)
        .environment(\.themeColors, ThemeColors.colors(for: .light))
}
