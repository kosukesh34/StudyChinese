//
//  SpeechRecognitionManager.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import Foundation
import Speech
import AVFoundation
import Combine

class SpeechRecognitionManager: ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var isAuthorized = false
    @Published var authorizationError: String?
    @Published var confidence: Float = 0.0
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isProcessing = false
    private var recordingTimer: Timer?
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.isAuthorized = true
                case .denied:
                    self?.authorizationError = "音声認識が拒否されました"
                case .restricted:
                    self?.authorizationError = "音声認識が制限されています"
                case .notDetermined:
                    self?.authorizationError = "音声認識の認証が未確定です"
                @unknown default:
                    self?.authorizationError = "不明なエラーが発生しました"
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                if !allowed {
                    self?.authorizationError = "マイクの使用許可が必要です"
                }
            }
        }
    }
    
    func startRecording() {
        guard isAuthorized && !isProcessing else { return }
        
        isProcessing = true
        
        // 既存のリソースを安全にクリーンアップ
        cleanupResources()
        
        // オーディオセッションの設定
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("オーディオセッションの設定に失敗しました: \(error)")
            isProcessing = false
            return
        }
        
        // 音声認識リクエストの作成
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("認識リクエストの作成に失敗しました")
            isProcessing = false
            return
        }
        
        // リアルタイム表示・高精度設定
        recognitionRequest.shouldReportPartialResults = true // 部分結果を有効にしてリアルタイム表示
        recognitionRequest.requiresOnDeviceRecognition = false // オンライン認識で精度向上
        
        let inputNode = audioEngine.inputNode
        
        // 中国語の音声認識を設定
        guard let chineseRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN")) else {
            print("中国語音声認識が利用できません")
            isProcessing = false
            return
        }
        
        recognitionTask = chineseRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                    
                    // 信頼度を計算（より正確な方法）
                    if !result.bestTranscription.segments.isEmpty {
                        let totalConfidence = result.bestTranscription.segments.reduce(0.0) { sum, segment in
                            return sum + segment.confidence
                        }
                        self.confidence = totalConfidence / Float(result.bestTranscription.segments.count)
                    }
                    
                    // 最終結果の場合は自動停止
                    if result.isFinal {
                        self.stopRecording()
                    }
                }
                
                if let error = error {
                    print("音声認識エラー: \(error)")
                    self.stopRecording()
                }
            }
        }
        
        // オーディオフォーマットの最適化
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            
            // UI更新を安定させるため
            DispatchQueue.main.async {
                self.isRecording = true
                self.recognizedText = ""
                self.confidence = 0.0
                self.isProcessing = false
            }
            
            // 安全のため自動停止タイマー（30秒）
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
                self?.stopRecording()
            }
            
        } catch {
            print("音声エンジンの開始に失敗しました: \(error)")
            isProcessing = false
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        cleanupResources()
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.isProcessing = false
        }
    }
    
    // 新しい練習セッション開始時に状態をリセット
    func resetSession() {
        cleanupResources()
        
        DispatchQueue.main.async {
            self.recognizedText = ""
            self.confidence = 0.0
            self.isRecording = false
            self.isProcessing = false
        }
    }
    
    private func cleanupResources() {
        // タイマーを停止
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // オーディオエンジンを停止
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // 認識タスクをキャンセル
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // 認識リクエストを終了
        recognitionRequest?.endAudio()
        recognitionRequest = nil
    }
    
    // より高精度なテキスト類似度計算（Levenshtein距離）
    func calculateSimilarity(original: String, recognized: String) -> Double {
        let originalCleaned = original.trimmingCharacters(in: .whitespacesAndNewlines)
        let recognizedCleaned = recognized.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if originalCleaned.isEmpty && recognizedCleaned.isEmpty { return 1.0 }
        if originalCleaned.isEmpty || recognizedCleaned.isEmpty { return 0.0 }
        
        // 完全一致の場合
        if originalCleaned == recognizedCleaned {
            return 1.0
        }
        
        // Levenshtein距離を使用した類似度計算
        let distance = levenshteinDistance(originalCleaned, recognizedCleaned)
        let maxLength = max(originalCleaned.count, recognizedCleaned.count)
        
        return 1.0 - (Double(distance) / Double(maxLength))
    }
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let s1Count = s1Array.count
        let s2Count = s2Array.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: s2Count + 1), count: s1Count + 1)
        
        for i in 0...s1Count {
            matrix[i][0] = i
        }
        
        for j in 0...s2Count {
            matrix[0][j] = j
        }
        
        for i in 1...s1Count {
            for j in 1...s2Count {
                let cost = s1Array[i-1] == s2Array[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                )
            }
        }
        
        return matrix[s1Count][s2Count]
    }
    
    // 単語レベルでの発音分析
    private func analyzeWordLevel(original: String, recognized: String) -> [WordLevelResult] {
        let originalWords = segmentChineseText(original)
        let recognizedWords = segmentChineseText(recognized)
        
        var results: [WordLevelResult] = []
        let maxCount = max(originalWords.count, recognizedWords.count)
        
        for i in 0..<maxCount {
            let targetWord = i < originalWords.count ? originalWords[i] : ""
            let spokenWord = i < recognizedWords.count ? recognizedWords[i] : ""
            
            if !targetWord.isEmpty {
                let wordSimilarity = calculateSimilarity(original: targetWord, recognized: spokenWord)
                let isCorrect = wordSimilarity >= 0.8 // 80%以上で正解とする
                
                let feedback: String
                if isCorrect {
                    feedback = "正確"
                } else if wordSimilarity >= 0.6 {
                    feedback = "もう少し"
                } else if spokenWord.isEmpty {
                    feedback = "未認識"
                } else {
                    feedback = "要練習"
                }
                
                results.append(WordLevelResult(
                    word: spokenWord,
                    targetWord: targetWord,
                    similarity: wordSimilarity,
                    confidence: confidence,
                    isCorrect: isCorrect,
                    feedback: feedback
                ))
            }
        }
        
        return results
    }
    
    // 中国語テキストを単語に分割（改良版）
    private func segmentChineseText(_ text: String) -> [String] {
        // スペース区切りがある場合はそれを使用
        if text.contains(" ") {
            return text.components(separatedBy: " ").filter { !$0.isEmpty }
        }
        
        // 句読点を除去
        let cleanedText = text.replacingOccurrences(of: "[。，、？！：；]", with: "", options: .regularExpression)
        
        // より智能な中国語分詞（簡易版）
        return segmentChineseTextIntelligently(cleanedText)
    }
    
    // 智能分詞（基本的なルールベース）
    private func segmentChineseTextIntelligently(_ text: String) -> [String] {
        var segments: [String] = []
        var currentSegment = ""
        var i = text.startIndex
        
        while i < text.endIndex {
            let char = String(text[i])
            
            // 2文字の一般的な組み合わせをチェック
            if i < text.index(before: text.endIndex) {
                let nextChar = String(text[text.index(after: i)])
                let twoCharWord = char + nextChar
                
                if isCommonTwoCharWord(twoCharWord) {
                    if !currentSegment.isEmpty {
                        segments.append(currentSegment)
                        currentSegment = ""
                    }
                    segments.append(twoCharWord)
                    i = text.index(i, offsetBy: 2)
                    continue
                }
            }
            
            // 単一文字の処理
            if isStandaloneChar(char) {
                if !currentSegment.isEmpty {
                    segments.append(currentSegment)
                    currentSegment = ""
                }
                segments.append(char)
            } else {
                currentSegment += char
            }
            
            i = text.index(after: i)
        }
        
        if !currentSegment.isEmpty {
            segments.append(currentSegment)
        }
        
        return segments.filter { !$0.isEmpty }
    }
    
    // 一般的な2文字単語かどうかをチェック
    private func isCommonTwoCharWord(_ word: String) -> Bool {
        let commonTwoCharWords = [
            "中国", "学习", "学習", "练习", "練習", "朋友", "老师", "老師", "学生", "学生",
            "今天", "明天", "昨天", "现在", "現在", "时间", "時間", "工作", "公司",
            "家里", "学校", "学校", "医院", "醫院", "银行", "銀行", "商店", "饭店",
            "喜欢", "喜歡", "知道", "认为", "認為", "觉得", "覺得", "希望", "想要",
            "什么", "什麼", "怎么", "怎麼", "为什么", "為什麼", "哪里", "哪裡"
        ]
        return commonTwoCharWords.contains(word)
    }
    
    // 独立した文字かどうかをチェック
    private func isStandaloneChar(_ char: String) -> Bool {
        let standaloneChars = [
            "我", "你", "他", "她", "它", "们", "們", "的", "了", "在", "是", "有", "不", "很", "也", "都",
            "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "百", "千", "万", "萬"
        ]
        return standaloneChars.contains(char)
    }
    
    // 改善された発音評価
    func evaluatePronunciation(original: String, recognized: String) -> PronunciationResult {
        let similarity = calculateSimilarity(original: original, recognized: recognized)
        let confidenceScore = Double(confidence)
        
        // 単語レベルの分析を実行
        let wordLevelResults = analyzeWordLevel(original: original, recognized: recognized)
        
        // より詳細な評価基準
        // 1. 音声認識の信頼度 (40%)
        // 2. テキストの類似度 (60%)
        let combinedScore = (similarity * 0.6) + (confidenceScore * 0.4)
        
        // より詳細なフィードバック
        let similarityPercent = Int(similarity * 100)
        let confidencePercent = Int(confidenceScore * 100)
        
        if combinedScore >= 0.9 {
            return PronunciationResult(
                score: combinedScore,
                grade: .excellent,
                feedback: "素晴らしい発音です！\n📊 類似度: \(similarityPercent)% | 信頼度: \(confidencePercent)%",
                wordLevelResults: wordLevelResults
            )
        } else if combinedScore >= 0.75 {
            return PronunciationResult(
                score: combinedScore,
                grade: .good,
                feedback: "とても良い発音です！\n📊 類似度: \(similarityPercent)% | 信頼度: \(confidencePercent)%",
                wordLevelResults: wordLevelResults
            )
        } else if combinedScore >= 0.5 {
            return PronunciationResult(
                score: combinedScore,
                grade: .fair,
                feedback: "もう少し練習しましょう。\n📊 類似度: \(similarityPercent)% | 信頼度: \(confidencePercent)%\n💡 目標: 類似度80%以上、信頼度70%以上",
                wordLevelResults: wordLevelResults
            )
        } else {
            return PronunciationResult(
                score: combinedScore,
                grade: .needsImprovement,
                feedback: "発音の練習を続けましょう。\n📊 類似度: \(similarityPercent)% | 信頼度: \(confidencePercent)%\n💡 ゆっくりはっきりと話してみてください",
                wordLevelResults: wordLevelResults
            )
        }
    }
}

struct WordLevelResult {
    let word: String
    let targetWord: String
    let similarity: Double
    let confidence: Float
    let isCorrect: Bool
    let feedback: String
}

struct PronunciationResult {
    let score: Double
    let grade: PronunciationGrade
    let feedback: String
    let wordLevelResults: [WordLevelResult]
}

enum PronunciationGrade {
    case excellent
    case good
    case fair
    case needsImprovement
    
    var emoji: String {
        switch self {
        case .excellent: return "🌟"
        case .good: return "👍"
        case .fair: return "😊"
        case .needsImprovement: return "🔄"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "orange"
        case .needsImprovement: return "red"
        }
    }
    
    var description: String {
        switch self {
        case .excellent:
            return "完璧な発音"
        case .good:
            return "良い発音"
        case .fair:
            return "練習が必要"
        case .needsImprovement:
            return "改善が必要"
        }
    }
}