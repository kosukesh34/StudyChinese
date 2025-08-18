import UIKit
import AVFoundation

class SoundsViewController: UIViewController {

    // AVAudioPlayerのインスタンスを作成する
    var audioPlayer: AVAudioPlayer?
    
    // 再生ボタンがタップされたときの処理
    @IBAction func playButtonTapped(_ sender: UIButton) {
        // 音声ファイルの名前と拡張子を指定する
        let audioFileName = "ex0.mp3"

        // 音声ファイルのパスを取得する
        guard let audioPath = Bundle.main.path(forResource: audioFileName, ofType: nil) else {
            print("\(audioFileName)が見つかりません")
            return
        }

        do {
            // AVAudioPlayerのインスタンスを作成する
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))

            // 音声ファイルを再生する
            audioPlayer?.play()
        } catch {
            print("音声ファイルの再生に失敗しました")
        }
    }
}
