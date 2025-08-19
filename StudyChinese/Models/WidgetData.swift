import Foundation

struct WidgetWordData: Codable {
    let number: String
    let word: String
    let pronunciation: String
    let meaning: String
}

struct WidgetQuiz: Codable {
    let id: String
    let wordData: WidgetWordData
    let options: [String]
    let correctAnswer: String
    let date: Date
    
    init(word: ChineseWord, allWords: [ChineseWord]) {
        self.id = UUID().uuidString
        self.wordData = WidgetWordData(
            number: word.number,
            word: word.word,
            pronunciation: word.pronunciation,
            meaning: word.meaning
        )
        self.correctAnswer = word.meaning
        self.date = Date()
        
        // 他の単語から間違った選択肢を3つ選ぶ
        let wrongOptions = allWords
            .filter { $0.id != word.id }
            .map { $0.meaning }
            .shuffled()
            .prefix(3)
        
        // 正解と間違った選択肢を混ぜてシャッフル
        self.options = ([correctAnswer] + wrongOptions).shuffled()
    }
}

class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.Memop.StudyChinese") ?? UserDefaults.standard
    private let quizKey = "daily_widget_quiz"
    private let dateKey = "last_quiz_date"
    
    private init() {}
    
    func getTodaysQuiz() -> WidgetQuiz? {
        guard let data = userDefaults.data(forKey: quizKey),
              let quiz = try? JSONDecoder().decode(WidgetQuiz.self, from: data) else {
            return nil
        }
        
        // 今日の日付と比較
        let calendar = Calendar.current
        if calendar.isDate(quiz.date, inSameDayAs: Date()) {
            return quiz
        }
        
        return nil
    }
    
    func generateTodaysQuiz(from words: [ChineseWord]) -> WidgetQuiz? {
        guard !words.isEmpty else { return nil }
        
        // 今日の日付を基にシードを設定（毎日同じ問題になるように）
        let today = Calendar.current.startOfDay(for: Date())
        let daysSinceReferenceDate = Int(today.timeIntervalSinceReferenceDate / 86400)
        
        var generator = SeededRandomNumberGenerator(seed: UInt64(daysSinceReferenceDate))
        let randomWord = words.randomElement(using: &generator)!
        
        let quiz = WidgetQuiz(word: randomWord, allWords: words)
        
        // 保存
        if let data = try? JSONEncoder().encode(quiz) {
            userDefaults.set(data, forKey: quizKey)
            userDefaults.set(today, forKey: dateKey)
        }
        
        return quiz
    }
    
    func checkAnswer(_ selectedAnswer: String, for quiz: WidgetQuiz) -> Bool {
        return selectedAnswer == quiz.correctAnswer
    }
}

// 毎日同じ問題を出すためのシード付きランダム生成器
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}
