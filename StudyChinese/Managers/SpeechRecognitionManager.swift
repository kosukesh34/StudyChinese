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
    
    // 改善された発音評価
    func evaluatePronunciation(original: String, recognized: String) -> PronunciationResult {
        let similarity = calculateSimilarity(original: original, recognized: recognized)
        let confidenceScore = Double(confidence)
        
        // 類似度と信頼度を組み合わせたスコア
        let combinedScore = (similarity * 0.7) + (confidenceScore * 0.3)
        
        if combinedScore >= 0.9 {
            return PronunciationResult(
                score: combinedScore,
                grade: .excellent,
                feedback: "素晴らしい発音です！完璧です。"
            )
        } else if combinedScore >= 0.75 {
            return PronunciationResult(
                score: combinedScore,
                grade: .good,
                feedback: "とても良い発音です。もう少しで完璧です。"
            )
        } else if combinedScore >= 0.5 {
            return PronunciationResult(
                score: combinedScore,
                grade: .fair,
                feedback: "良い努力です。発音をもう少し練習してみましょう。"
            )
        } else {
            return PronunciationResult(
                score: combinedScore,
                grade: .needsImprovement,
                feedback: "もう一度お手本を聞いて、ゆっくり練習してみましょう。"
            )
        }
    }
}

struct PronunciationResult {
    let score: Double
    let grade: PronunciationGrade
    let feedback: String
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
}