import Foundation

class StudyDataManager: ObservableObject {
    static let shared = StudyDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let studiedWordsKey = "studied_words"
    private let favoriteWordsKey = "favorite_words"
    private let quizStatsKey = "quiz_stats"
    private let speechPracticeStatsKey = "speech_practice_stats"
    private let memorizationStatsKey = "memorization_stats"
    
    // 学習済み単語のID配列
    @Published var studiedWordIds: Set<String> = []
    
    // お気に入り単語のID配列
    @Published var favoriteWordIds: Set<String> = []
    
    // クイズ統計
    @Published var quizStats: QuizStats = QuizStats()
    
    // 音声練習統計
    @Published var speechPracticeStats: SpeechPracticeStats = SpeechPracticeStats()
    
    // 暗記カード統計
    @Published var memorizationStats: MemorizationStats = MemorizationStats()
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Loading
    private func loadData() {
        loadStudiedWords()
        loadFavoriteWords()
        loadQuizStats()
        loadSpeechPracticeStats()
        loadMemorizationStats()
    }
    
    private func loadStudiedWords() {
        if let data = userDefaults.data(forKey: studiedWordsKey),
           let wordIds = try? JSONDecoder().decode(Set<String>.self, from: data) {
            studiedWordIds = wordIds
        }
    }
    
    private func loadFavoriteWords() {
        if let data = userDefaults.data(forKey: favoriteWordsKey),
           let wordIds = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteWordIds = wordIds
        }
    }
    
    private func loadQuizStats() {
        if let data = userDefaults.data(forKey: quizStatsKey),
           let stats = try? JSONDecoder().decode(QuizStats.self, from: data) {
            quizStats = stats
        }
    }
    
    private func loadSpeechPracticeStats() {
        if let data = userDefaults.data(forKey: speechPracticeStatsKey),
           let stats = try? JSONDecoder().decode(SpeechPracticeStats.self, from: data) {
            speechPracticeStats = stats
        }
    }
    
    private func loadMemorizationStats() {
        if let data = userDefaults.data(forKey: memorizationStatsKey),
           let stats = try? JSONDecoder().decode(MemorizationStats.self, from: data) {
            memorizationStats = stats
        }
    }
    
    // MARK: - Data Saving
    private func saveStudiedWords() {
        if let data = try? JSONEncoder().encode(studiedWordIds) {
            userDefaults.set(data, forKey: studiedWordsKey)
        }
    }
    
    private func saveFavoriteWords() {
        if let data = try? JSONEncoder().encode(favoriteWordIds) {
            userDefaults.set(data, forKey: favoriteWordsKey)
        }
    }
    
    private func saveQuizStats() {
        if let data = try? JSONEncoder().encode(quizStats) {
            userDefaults.set(data, forKey: quizStatsKey)
        }
    }
    
    private func saveSpeechPracticeStats() {
        if let data = try? JSONEncoder().encode(speechPracticeStats) {
            userDefaults.set(data, forKey: speechPracticeStatsKey)
        }
    }
    
    private func saveMemorizationStats() {
        if let data = try? JSONEncoder().encode(memorizationStats) {
            userDefaults.set(data, forKey: memorizationStatsKey)
        }
    }
    
    // MARK: - Public Methods
    
    // 学習済み単語の管理
    func markAsStudied(_ wordId: String) {
        studiedWordIds.insert(wordId)
        saveStudiedWords()
    }
    
    func isStudied(_ wordId: String) -> Bool {
        return studiedWordIds.contains(wordId)
    }
    
    // お気に入り単語の管理
    func toggleFavorite(_ wordId: String) {
        if favoriteWordIds.contains(wordId) {
            favoriteWordIds.remove(wordId)
        } else {
            favoriteWordIds.insert(wordId)
        }
        saveFavoriteWords()
    }
    
    func isFavorite(_ wordId: String) -> Bool {
        return favoriteWordIds.contains(wordId)
    }
    
    // クイズ統計の更新
    func updateQuizStats(correct: Bool, quizTypeName: String) {
        quizStats.totalQuestions += 1
        if correct {
            quizStats.correctAnswers += 1
        }
        
        switch quizTypeName {
        case "meaningToWord":
            quizStats.meaningToWordCount += 1
        case "wordToMeaning":
            quizStats.wordToMeaningCount += 1
        case "pronunciationToWord":
            quizStats.pronunciationToWordCount += 1
        case "exampleToMeaning":
            quizStats.exampleToMeaningCount += 1
        default:
            break
        }
        
        quizStats.lastStudyDate = Date()
        saveQuizStats()
    }
    
    // 音声練習統計の更新
    func updateSpeechPracticeStats(accuracy: Float) {
        speechPracticeStats.totalAttempts += 1
        speechPracticeStats.totalAccuracy += accuracy
        speechPracticeStats.lastStudyDate = Date()
        saveSpeechPracticeStats()
    }
    
    // 暗記カード統計の更新
    func updateMemorizationStats(correct: Bool) {
        memorizationStats.totalCards += 1
        if correct {
            memorizationStats.correctCards += 1
        }
        memorizationStats.lastStudyDate = Date()
        saveMemorizationStats()
    }
    
    // 学習ストリークの計算
    func getStudyStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var streak = 0
        var checkDate = today
        
        // 過去の学習日をチェック
        while true {
            let hasStudiedOnDate = hasStudiedOn(date: checkDate)
            if hasStudiedOnDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func hasStudiedOn(date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        // 各統計から該当日の学習があったかチェック
        if let quizDate = quizStats.lastStudyDate,
           calendar.isDate(quizDate, inSameDayAs: targetDate) {
            return true
        }
        
        if let speechDate = speechPracticeStats.lastStudyDate,
           calendar.isDate(speechDate, inSameDayAs: targetDate) {
            return true
        }
        
        if let memorizationDate = memorizationStats.lastStudyDate,
           calendar.isDate(memorizationDate, inSameDayAs: targetDate) {
            return true
        }
        
        return false
    }
}

// MARK: - Data Models

struct QuizStats: Codable {
    var totalQuestions: Int = 0
    var correctAnswers: Int = 0
    var meaningToWordCount: Int = 0
    var wordToMeaningCount: Int = 0
    var pronunciationToWordCount: Int = 0
    var exampleToMeaningCount: Int = 0
    var lastStudyDate: Date?
    
    var accuracy: Double {
        return totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) : 0.0
    }
}

struct SpeechPracticeStats: Codable {
    var totalAttempts: Int = 0
    var totalAccuracy: Float = 0.0
    var lastStudyDate: Date?
    
    var averageAccuracy: Float {
        return totalAttempts > 0 ? totalAccuracy / Float(totalAttempts) : 0.0
    }
}

struct MemorizationStats: Codable {
    var totalCards: Int = 0
    var correctCards: Int = 0
    var lastStudyDate: Date?
    
    var accuracy: Double {
        return totalCards > 0 ? Double(correctCards) / Double(totalCards) : 0.0
    }
}
