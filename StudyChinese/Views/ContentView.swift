//
//  ContentView.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var wordData = ChineseWordData()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                WordListView(wordData: wordData)
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tag(0)
            .tabItem {
                Image(systemName: "list.bullet")
                Text("単語リスト")
            }
            
            QuizView(wordData: wordData)
                .tag(1)
                .tabItem {
                    Image(systemName: "questionmark.circle")
                    Text("クイズ")
                }
            
            MemorizationView(wordData: wordData)
                .tag(2)
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("暗記")
                }
            
            SpeechPracticeView(wordData: wordData)
                .tag(3)
                .tabItem {
                    Image(systemName: "mic")
                    Text("音声練習")
                }
            
            StudyProgressView(wordData: wordData)
                .tag(4)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("学習進捗")
                }
        }
        .accentColor(ModernDesignSystem.Colors.accent)
    }
}

#Preview {
    ContentView()
}