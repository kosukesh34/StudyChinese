//
//  ChineseWordData.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import Foundation
import Combine

// CSVデータを管理するObservableObjectクラス
class ChineseWordData: ObservableObject {
    @Published var words: [ChineseWord] = []
    @Published var filteredWords: [ChineseWord] = []
    @Published var selectedIndex: Int = 0
    @Published var segmentedIndex: Int = 0
    @Published var searchText: String = ""
    @Published var studiedWords: Set<String> = []
    @Published var favoriteWords: Set<String> = []
    
    init() {
        loadData()
        updateFilteredWords()
    }
    
    // CSVファイルからデータを読み込み
    private func loadData() {
        if let csvBundle = Bundle.main.path(forResource: "中国語　処理後", ofType: "csv") {
            do {
                let csvData = try String(contentsOfFile: csvBundle, encoding: .utf8)
                var dataArray = csvData.components(separatedBy: "\n")
                dataArray.removeLast() // 最後の空行を削除
                
                self.words = dataArray.map { ChineseWord(csvRow: $0) }
                
                // ランダムなインデックスを設定
                self.selectedIndex = Int.random(in: 0..<min(394, words.count))
                
            } catch {
                print("CSVファイル読み込みエラー: \(error)")
            }
        } else {
            print("CSVファイルが見つかりません")
        }
    }
    
    // 次の単語に移動
    func nextWord() {
        if selectedIndex < words.count - 1 {
            selectedIndex += 1
        } else {
            selectedIndex = 0
        }
    }
    
    // 前の単語に移動
    func previousWord() {
        if selectedIndex > 0 {
            selectedIndex -= 1
        } else {
            selectedIndex = words.count - 1
        }
    }
    
    // 現在選択されている単語を取得
    var currentWord: ChineseWord? {
        guard selectedIndex < words.count else { return nil }
        return words[selectedIndex]
    }
    
    // 検索機能
    func updateFilteredWords() {
        if searchText.isEmpty {
            filteredWords = words
        } else {
            filteredWords = words.filter { word in
                word.word.localizedCaseInsensitiveContains(searchText) ||
                word.meaning.localizedCaseInsensitiveContains(searchText) ||
                word.pronunciation.localizedCaseInsensitiveContains(searchText) ||
                word.example.localizedCaseInsensitiveContains(searchText) ||
                word.exampleMeaning.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // 学習済みとしてマーク
    func markAsStudied(word: ChineseWord) {
        studiedWords.insert(word.number)
    }
    
    // お気に入りとしてマーク
    func toggleFavorite(word: ChineseWord) {
        if favoriteWords.contains(word.number) {
            favoriteWords.remove(word.number)
        } else {
            favoriteWords.insert(word.number)
        }
    }
    
    // お気に入りかどうか確認
    func isFavorite(word: ChineseWord) -> Bool {
        return favoriteWords.contains(word.number)
    }
    
    // 学習済みかどうか確認
    func isStudied(word: ChineseWord) -> Bool {
        return studiedWords.contains(word.number)
    }
    
    // ランダムクイズ用の単語を取得
    func getRandomWordsForQuiz(count: Int = 4) -> [ChineseWord] {
        return Array(words.shuffled().prefix(count))
    }
    
    // 未学習の単語を取得
    func getUnstudiedWords() -> [ChineseWord] {
        return words.filter { !isStudied(word: $0) }
    }
}
