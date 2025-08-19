//
//  ChineseWord.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import Foundation

// 中国語単語データモデル
struct ChineseWord: Identifiable, Hashable {
    let id = UUID()
    let number: String      // Num1
    let word: String        // Word2
    let meaning: String     // Mean3
    let pronunciation: String // Pro4
    let example: String     // Ex5
    let examplePronunciation: String // ExPro6
    let exampleMeaning: String // ExMean7
    let detail: String      // Detail8
    let csvRowIndex: Int    // 実際のCSV行番号（音声ファイル対応用）
    
    // CSV行から ChineseWord を作成するイニシャライザ
    init(csvRow: String, csvRowIndex: Int = 0) {
        let components = csvRow.components(separatedBy: ",")
        
        // デフォルト値を設定してアクセス範囲外エラーを防ぐ
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
    
    // 手動でデータを作成するイニシャライザ
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
    
    // 行番号を取得（0ベース）
    var index: Int {
        return Int(number) ?? 0
    }
    
    // 背景色を決定するメソッド
    var backgroundColor: String {
        let index = self.index
        if index >= 700 {
            return "red"
        } else if index >= 300 {
            return "green"
        } else {
            return "blue"
        }
    }
}
