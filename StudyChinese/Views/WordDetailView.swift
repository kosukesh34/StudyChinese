//
//  WordDetailView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct WordDetailView: View {
    let word: ChineseWord?
    let segmentIndex: Int
    @ObservedObject var audioPlayer: AudioPlayerManager
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if let word = word {
                // 上部のナビゲーションボタン
                HStack {
                    Button(action: onPrevious) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(action: onNext) {
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // 単語詳細表示
                VStack(spacing: 15) {
                    // 番号
                    Text(word.number)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // 単語
                    Text(word.word)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // 発音（セグメントに応じて表示/非表示）
                    if segmentIndex == 0 {
                        Text(word.pronunciation)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    // 意味（セグメントに応じて表示/非表示）
                    if segmentIndex == 0 {
                        Text(word.meaning)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    
                    // 例文
                    Text(word.example)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // 例文発音（セグメントに応じて表示/非表示）
                    if segmentIndex == 0 {
                        Text(word.examplePronunciation)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // 例文意味（セグメントに応じて表示/非表示）
                    if segmentIndex == 0 {
                        Text(word.exampleMeaning)
                            .font(.body)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // 詳細
                    Text(word.detail.isEmpty ? "なし" : word.detail)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                Spacer()
                
                // 音声再生ボタン
                HStack(spacing: 40) {
                    Button(action: {
                        // CSVの番号をそのまま使用（AudioPlayerManagerで-1の調整済み）
                        let csvNumber = Int(word.number) ?? 1
                        audioPlayer.playAudio(index: csvNumber)
                    }) {
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            Text("単語音声")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        // CSVの番号をそのまま使用（AudioPlayerManagerで-1の調整済み）
                        let csvNumber = Int(word.number) ?? 1
                        audioPlayer.playExampleAudio(index: csvNumber)
                    }) {
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            Text("例文音声")
                                .font(.caption)
                        }
                    }
                }
                .padding(.bottom, 50)
                
            } else {
                Text("データが読み込まれていません")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    let audioPlayer = AudioPlayerManager()
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
    
    return WordDetailView(
        word: sampleWord,
        segmentIndex: 0,
        audioPlayer: audioPlayer,
        onNext: {},
        onPrevious: {}
    )
}
