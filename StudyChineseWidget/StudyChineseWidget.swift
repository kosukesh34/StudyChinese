import WidgetKit
import SwiftUI

struct StudyChineseWidget: Widget {
    let kind: String = "StudyChineseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuizProvider()) { entry in
            QuizWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("中国語クイズ")
        .description("毎日新しい中国語クイズに挑戦しましょう！")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct QuizEntry: TimelineEntry {
    let date: Date
    let quiz: WidgetQuiz?
    let isPlaceholder: Bool
    
    init(date: Date, quiz: WidgetQuiz? = nil, isPlaceholder: Bool = false) {
        self.date = date
        self.quiz = quiz
        self.isPlaceholder = isPlaceholder
    }
}

struct QuizProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuizEntry {
        let sampleWordData = WidgetWordData(
            number: "1",
            word: "你好",
            pronunciation: "nǐ hǎo",
            meaning: "こんにちは"
        )
        let sampleQuiz = WidgetQuiz(
            id: "sample",
            wordData: sampleWordData,
            options: ["こんにちは", "ありがとう", "さようなら", "すみません"],
            correctAnswer: "こんにちは",
            date: Date()
        )
        return QuizEntry(date: Date(), quiz: sampleQuiz, isPlaceholder: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuizEntry) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuizEntry>) -> ()) {
        let currentDate = Date()
        
        // メモリクリーンアップを実行
        WidgetDataManager.shared.clearOldData()
        
        // 今日のクイズを取得または生成
        var quiz = WidgetDataManager.shared.getTodaysQuiz()
        if quiz == nil {
            let words = loadChineseWords()
            quiz = WidgetDataManager.shared.generateTodaysQuiz(from: words)
        }
        
        let entry = QuizEntry(date: currentDate, quiz: quiz)
        
        // 明日の午前0時に次回更新
        let calendar = Calendar.current
        let nextMidnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        
        completion(timeline)
    }
    
    private func loadChineseWords() -> [ChineseWord] {
        // メモリ効率のためWidgetでは固定の基本単語のみを使用
        return getFallbackWords()
    }
    
    private func createFallbackWords() -> [ChineseWord] {
        return getFallbackWords()
    }
}

struct QuizWidgetView: View {
    let entry: QuizEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let quiz = entry.quiz {
            switch family {
            case .systemMedium:
                MediumWidgetView(quiz: quiz, isPlaceholder: entry.isPlaceholder)
            case .systemLarge:
                LargeWidgetView(quiz: quiz, isPlaceholder: entry.isPlaceholder)
            default:
                MediumWidgetView(quiz: quiz, isPlaceholder: entry.isPlaceholder)
            }
        } else {
            // データが無い場合のフォールバック
            VStack {
                Image(systemName: "book.closed")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("クイズデータを読み込み中...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct MediumWidgetView: View {
    let quiz: WidgetQuiz
    let isPlaceholder: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("中国語クイズ")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("No.\(quiz.wordData.number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            // 問題
            VStack(alignment: .leading, spacing: 4) {
                Text("「\(quiz.wordData.word)」の意味は？")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if !quiz.wordData.pronunciation.isEmpty {
                    Text("[\(quiz.wordData.pronunciation)]")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // フッター
            HStack {
                Spacer()
                Text("アプリで回答しよう！")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .italic()
            }
        }
        .padding()
        .redacted(reason: isPlaceholder ? .placeholder : [])
    }
}

struct LargeWidgetView: View {
    let quiz: WidgetQuiz
    let isPlaceholder: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("中国語クイズ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("No.\(quiz.wordData.number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "questionmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            // 問題
            VStack(alignment: .leading, spacing: 8) {
                Text("「\(quiz.wordData.word)」の意味は？")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if !quiz.wordData.pronunciation.isEmpty {
                    Text("[\(quiz.wordData.pronunciation)]")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            // 全選択肢表示
            VStack(alignment: .leading, spacing: 6) {
                Text("選択肢:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                ForEach(Array(quiz.options.enumerated()), id: \.offset) { index, option in
                    HStack {
                        Text("\(["A", "B", "C", "D"][index]).")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(option)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // フッター
            HStack {
                Spacer()
                Text("アプリで回答しよう！")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .italic()
            }
        }
        .padding()
        .redacted(reason: isPlaceholder ? .placeholder : [])
    }
}

#Preview(as: .systemMedium) {
    StudyChineseWidget()
} timeline: {
    let sampleWordData = WidgetWordData(
        number: "1",
        word: "你好",
        pronunciation: "nǐ hǎo",
        meaning: "こんにちは"
    )
    let sampleQuiz = WidgetQuiz(
        id: "sample",
        wordData: sampleWordData,
        options: ["こんにちは", "ありがとう", "さようなら", "すみません"],
        correctAnswer: "こんにちは",
        date: Date()
    )
    QuizEntry(date: .now, quiz: sampleQuiz)
}