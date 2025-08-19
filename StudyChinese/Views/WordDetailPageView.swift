//
//  WordDetailPageView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct WordDetailPageView: View {
    @ObservedObject var wordData: ChineseWordData
    let selectedWord: ChineseWord
    @State private var selectedSegment = 0
    @State private var currentWordIndex: Int
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    init(wordData: ChineseWordData, selectedWord: ChineseWord) {
        self.wordData = wordData
        self.selectedWord = selectedWord
        // CSVの番号は1から始まるが、配列のインデックスは0から始まるため-1する
        self._currentWordIndex = State(initialValue: selectedWord.index - 1)
    }
    
    var currentWord: ChineseWord? {
        guard currentWordIndex < wordData.words.count else { return nil }
        return wordData.words[currentWordIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // セグメントコントロール
            Picker("表示モード", selection: $selectedSegment) {
                Text("全て表示").tag(0)
                Text("テストモード").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // タブビュー
            TabView {
                // 第1タブ
                WordDetailView(
                    word: currentWord,
                    segmentIndex: selectedSegment,
                    audioPlayer: audioPlayer,
                    onNext: nextWord,
                    onPrevious: previousWord
                )
                .tabItem {
                    Text("詳細1")
                }
                
                // 第2タブ
                WordDetailView(
                    word: currentWord,
                    segmentIndex: selectedSegment,
                    audioPlayer: audioPlayer,
                    onNext: nextWord,
                    onPrevious: previousWord
                )
                .tabItem {
                    Text("詳細2")
                }
                
                // 第3タブ
                WordDetailView(
                    word: currentWord,
                    segmentIndex: selectedSegment,
                    audioPlayer: audioPlayer,
                    onNext: nextWord,
                    onPrevious: previousWord
                )
                .tabItem {
                    Text("詳細3")
                }
            }
            .onAppear {
                // 表示時に音声を自動再生
                if let word = currentWord {
                    let csvNumber = Int(word.number) ?? 1
                    audioPlayer.playAudio(index: csvNumber)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // お気に入りボタン
                if let word = currentWord {
                    Button(action: {
                        wordData.toggleFavorite(word: word)
                    }) {
                        Image(systemName: wordData.isFavorite(word: word) ? "heart.fill" : "heart")
                            .foregroundColor(wordData.isFavorite(word: word) ? .red : .gray)
                    }
                }
                
                // 音声ボタン
                Button("音声") {
                    if let word = currentWord {
                        let csvNumber = Int(word.number) ?? 1
                        audioPlayer.playAudio(index: csvNumber)
                    }
                }
            }
        }
    }
    
    private func nextWord() {
        if currentWordIndex < wordData.words.count - 1 {
            currentWordIndex += 1
        } else {
            currentWordIndex = 0
        }
        
        // 音声を自動再生
        if let word = currentWord {
            let csvNumber = Int(word.number) ?? 1
            audioPlayer.playAudio(index: csvNumber)
        }
    }
    
    private func previousWord() {
        if currentWordIndex > 0 {
            currentWordIndex -= 1
        } else {
            currentWordIndex = wordData.words.count - 1
        }
        
        // 音声を自動再生
        if let word = currentWord {
            let csvNumber = Int(word.number) ?? 1
            audioPlayer.playAudio(index: csvNumber)
        }
    }
}

#Preview {
    let wordData = ChineseWordData()
    let sampleWord = ChineseWord(
        number: "1",
        word: "人",
        meaning: "人",
        pronunciation: "rén",
        example: "他是哪国人？",
        examplePronunciation: "Tā shì nǎ guó rén?",
        exampleMeaning: "彼はどこの国の人ですか？",
        detail: "疑問詞疑問文"
    )
    
    return NavigationView {
        WordDetailPageView(wordData: wordData, selectedWord: sampleWord)
    }
}
