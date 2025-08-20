//
//  AudioPlayerManager.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/20/25.
//

import AVFoundation
import Combine

// 音声再生を管理するクラス
class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    @Published var isPlaying = false
    
    // 通常の音声ファイルを再生
    func playAudio(index: Int) {
        // CSVの番号は1から始まるが、音声ファイルは0から始まるため-1する
        let audioIndex = index - 1
        guard let path = Bundle.main.path(forResource: "\(audioIndex)", ofType: "mp3") else {
            print("音声ファイルが見つかりません: \(audioIndex).mp3 (CSV番号: \(index))")
            return
        }
        
        playAudioFile(path: path)
    }
    
    // 例文の音声ファイルを再生
    func playExampleAudio(index: Int) {
        // CSVの番号は1から始まるが、音声ファイルは0から始まるため-1する
        let audioIndex = index - 1
        guard let path = Bundle.main.path(forResource: "ex\(audioIndex)", ofType: "mp3") else {
            print("例文音声ファイルが見つかりません: ex\(audioIndex).mp3 (CSV番号: \(index))")
            return
        }
        
        playAudioFile(path: path)
    }
    
    // 長文音声ファイルを再生
    func playLongTextAudio(fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".mp3", with: ""), ofType: "mp3") else {
            print("長文音声ファイルが見つかりません: \(fileName)")
            return
        }
        
        playAudioFile(path: path)
    }
    
    // 共通の音声再生処理
    private func playAudioFile(path: String) {
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player?.delegate = self
            player?.play()
            isPlaying = true
        } catch {
            print("音声再生に失敗しました: \(error)")
        }
    }
    
    // 音声再生停止
    func stopAudio() {
        player?.stop()
        isPlaying = false
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        print("音声再生完了")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        if let error = error {
            print("音声デコードエラー: \(error)")
        }
    }
}
