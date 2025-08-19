import Foundation

// Widget用のデータ型定義
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
    
    init(id: String, wordData: WidgetWordData, options: [String], correctAnswer: String, date: Date) {
        self.id = id
        self.wordData = wordData
        self.options = options
        self.correctAnswer = correctAnswer
        self.date = date
    }
    
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
        let otherWords = allWords.filter { $0.id != word.id }
        let wrongOptions = Array(otherWords.shuffled().prefix(3)).map { $0.meaning }
        
        // 正解と間違った選択肢を混ぜてシャッフル
        self.options = ([correctAnswer] + wrongOptions).shuffled()
    }
}

// ChineseWord用の基本定義
struct ChineseWord: Identifiable, Hashable, Codable {
    let id = UUID()
    let number: String
    let word: String
    let meaning: String
    let pronunciation: String
    let example: String
    let examplePronunciation: String
    let exampleMeaning: String
    let detail: String
    let csvRowIndex: Int
    
    init(csvRow: String, csvRowIndex: Int = 0) {
        let components = csvRow.components(separatedBy: ",")
        self.number = components.count > 0 ? components[0] : ""
        self.word = components.count > 1 ? components[1] : ""
        self.meaning = components.count > 2 ? components[2] : ""
        self.pronunciation = components.count > 3 ? components[3] : ""
        self.example = components.count > 4 ? components[4] : ""
        self.examplePronunciation = components.count > 5 ? components[5] : ""
        self.exampleMeaning = components.count > 6 ? components[6] : ""
        self.detail = components.count > 7 ? components[7] : ""
        self.csvRowIndex = csvRowIndex
    }
    
    init(number: String, word: String, meaning: String, pronunciation: String,
         example: String, examplePronunciation: String, exampleMeaning: String, detail: String, csvRowIndex: Int = 0) {
        self.number = number
        self.word = word
        self.meaning = meaning
        self.pronunciation = pronunciation
        self.example = example
        self.examplePronunciation = examplePronunciation
        self.exampleMeaning = exampleMeaning
        self.detail = detail
        self.csvRowIndex = csvRowIndex
    }
    
    var index: Int {
        return Int(number) ?? 0
    }
}

class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.Memop.StudyChinese") ?? UserDefaults.standard
    private let quizKey = "daily_widget_quiz"
    private let dateKey = "last_quiz_date"
    
    private init() {}
    
    // メモリクリーンアップ
    func clearOldData() {
        let keys = ["daily_widget_quiz", "last_quiz_date"]
        for key in keys {
            if let data = userDefaults.object(forKey: key) as? Data, data.count > 10000 {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
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

// Widget用の軽量CSVファイル読み込み関数（メモリ効率重視）
func loadLimitedCSVDataInWidget(maxCount: Int = 50) -> [ChineseWord] {
    // Widget拡張のBundleでCSVファイルを探す
    guard let csvBundle = Bundle.main.path(forResource: "中国語　処理後", ofType: "csv") else {
        print("Widget: CSVファイルが見つかりません")
        return getFallbackWords()
    }
    
    do {
        // ファイルを1行ずつ読み込んでメモリ使用量を削減
        let csvContent = try String(contentsOfFile: csvBundle, encoding: .utf8)
        let lines = csvContent.components(separatedBy: .newlines)
        
        var words: [ChineseWord] = []
        let maxLines = min(maxCount, lines.count)
        
        // 制限された数の単語のみを読み込み
        for i in 0..<maxLines {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if !line.isEmpty {
                let word = ChineseWord(csvRow: line, csvRowIndex: i + 1)
                words.append(word)
            }
        }
        
        print("Widget: CSVから\(words.count)個の単語を読み込みました（制限: \(maxCount)）")
        return words.isEmpty ? getFallbackWords() : words
    } catch {
        print("Widget: CSVファイル読み込みエラー: \(error)")
        return getFallbackWords()
    }
}

// Widget用の軽量フォールバック単語（メモリ効率重視）
func getFallbackWords() -> [ChineseWord] {
    return [
        ChineseWord(number: "1", word: "你好", meaning: "こんにちは", pronunciation: "nǐ hǎo", 
                   example: "你好！", examplePronunciation: "nǐ hǎo!", 
                   exampleMeaning: "こんにちは！", detail: "挨拶", csvRowIndex: 1),
        ChineseWord(number: "2", word: "谢谢", meaning: "ありがとう", pronunciation: "xiè xiè",
                   example: "谢谢！", examplePronunciation: "xiè xiè!",
                   exampleMeaning: "ありがとう！", detail: "感謝", csvRowIndex: 2),
        ChineseWord(number: "3", word: "再见", meaning: "さようなら", pronunciation: "zài jiàn",
                   example: "再见！", examplePronunciation: "zài jiàn!",
                   exampleMeaning: "さようなら！", detail: "別れ", csvRowIndex: 3),
        ChineseWord(number: "4", word: "对不起", meaning: "すみません", pronunciation: "duì bù qǐ",
                   example: "对不起！", examplePronunciation: "duì bù qǐ!",
                   exampleMeaning: "すみません！", detail: "謝罪", csvRowIndex: 4),
        ChineseWord(number: "5", word: "请", meaning: "お願いします", pronunciation: "qǐng",
                   example: "请坐！", examplePronunciation: "qǐng zuò!",
                   exampleMeaning: "座ってください！", detail: "依頼", csvRowIndex: 5),
        ChineseWord(number: "6", word: "是", meaning: "はい", pronunciation: "shì",
                   example: "是的。", examplePronunciation: "shì de.",
                   exampleMeaning: "はい。", detail: "肯定", csvRowIndex: 6),
        ChineseWord(number: "7", word: "不", meaning: "いいえ", pronunciation: "bù",
                   example: "不是。", examplePronunciation: "bù shì.",
                   exampleMeaning: "いいえ。", detail: "否定", csvRowIndex: 7),
        ChineseWord(number: "8", word: "水", meaning: "水", pronunciation: "shuǐ",
                   example: "我要水。", examplePronunciation: "wǒ yào shuǐ.",
                   exampleMeaning: "水をください。", detail: "飲み物", csvRowIndex: 8)
    ]
}

// 毎日同じ問題を出すためのシード付きランダム生成器
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}
