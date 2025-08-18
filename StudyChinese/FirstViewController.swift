//
//  FirstViewController.swift
//  PageTransition
//
//  Created by Kosuke Shigematsu on 5/1/23.
//

import UIKit
import AVFoundation
var selfCounter = 0 //各自で番号を確認


class FirstViewController: UIViewController,AVAudioPlayerDelegate{
    var player:AVAudioPlayer!
    
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var label0: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label2: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.audioPlay()
        label0.text = Num1[indexNum]
        Label1.text = Word2[indexNum]
        label3.text = Pro4[indexNum]
        label2.text = Mean3[indexNum]
        label4.text = Ex5[indexNum]
        label5.text = ExPro6[indexNum]
        label6.text = ExMean7[indexNum]
        if Detail8[indexNum] == ""{
            label7.text = "なし"
        } else {
            label7.text = Detail8[indexNum]
        }
        
        // Do any additional setup after loading the view.
    }
    @IBAction func RightAction(_ sender: Any) {
        if indexNum != 1199{
            indexNum += 1
        } else {
            indexNum = 0
        }
        viewDidLoad()
    }
    
    @IBAction func LeftAction(_ sender: Any) {
        if indexNum != 0 {
            indexNum -= 1
        } else {
            indexNum = 1199
        }
        viewDidLoad()
    }
    
    @IBAction func ExButtonAction(_ sender: Any) {
        guard let path = Bundle.main.path(forResource: "ex\(indexNum)", ofType: "mp3") else {
            print("file not found")
            return
        }
        
        //音声ファイルの読み込みと再生
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player.delegate = self
            player.play()
        }catch{
            print("Playback failed")
        }
    }
    @IBAction func ButtonAction(_ sender: Any) {
        guard let path = Bundle.main.path(forResource: "\(indexNum)", ofType: "mp3") else {
            print("file not found")
            return
        }
        
        //音声ファイルの読み込みと再生
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player.delegate = self
            player.play()
        }catch{
            print("Playback failed")
        }
        
    }
    func audioPlay(){
        //ファイルパスの取得
        guard let path = Bundle.main.path(forResource: "\(indexNum)", ofType: "mp3") else {
            print("file not found")
            return
        }
        
        //音声ファイルの読み込みと再生
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player.delegate = self
            player.play()
        }catch{
            print("Playback failed")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finish!")
    }
    @IBAction func segmatationAction(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            label0.text = Num1[indexNum]
            Label1.text = Word2[indexNum]
            label3.text = Pro4[indexNum]
            label2.text = Mean3[indexNum]
            label4.text = Ex5[indexNum]
            label5.text = ExPro6[indexNum]
            label6.text = ExMean7[indexNum]
            if Detail8[indexNum] == ""{
                label7.text = "なし"
            } else {
                label7.text = Detail8[indexNum]
            }
        case 1 :
            label0.text = Num1[indexNum]
            Label1.text = Word2[indexNum]
            label3.text = ""
            label2.text = ""
            label4.text = Ex5[indexNum]
            label5.text = ""
            label6.text = ""
            if Detail8[indexNum] == ""{
                label7.text = "なし"
            } else {
                label7.text = Detail8[indexNum]
            }
        default:
            label0.text = Num1[indexNum]
            Label1.text = Word2[indexNum]
            label3.text = Pro4[indexNum]
            label2.text = Mean3[indexNum]
            label4.text = Ex5[indexNum]
            label5.text = ExPro6[indexNum]
            label6.text = ExMean7[indexNum]
            if Detail8[indexNum] == ""{
                label7.text = "なし"
            } else {
                label7.text = Detail8[indexNum]
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selfCounter == 0{
        }
        else if selfCounter == 2{
            indexNum -= 1
        } else if selfCounter == 3{
            indexNum += 1
        }
        label0.text = Num1[indexNum]
        Label1.text = Word2[indexNum]
        label3.text = Pro4[indexNum]
        label2.text = Mean3[indexNum]
        label4.text = Ex5[indexNum]
        label5.text = ExPro6[indexNum]
        label6.text = ExMean7[indexNum]
        if Detail8[indexNum] == ""{
            label7.text = "なし"
        } else {
            label7.text = Detail8[indexNum]
        }
        selfCounter = 1
        
        switch segmentedNumber {
        case 0:
            label0.text = Num1[indexNum]
            Label1.text = Word2[indexNum]
            label3.text = Pro4[indexNum]
            label2.text = Mean3[indexNum]
            label4.text = Ex5[indexNum]
            label5.text = ExPro6[indexNum]
            label6.text = ExMean7[indexNum]
            if Detail8[indexNum] == ""{
                label7.text = "なし"
            } else {
                label7.text = Detail8[indexNum]
            }
        case 1 :
            label0.text = Num1[indexNum]
            Label1.text = Word2[indexNum]
            label3.text = ""
            label2.text = ""
            label4.text = Ex5[indexNum]
            label5.text = ""
            label6.text = ""
            if Detail8[indexNum] == ""{
                label7.text = "なし"
            } else {
                label7.text = Detail8[indexNum]
            }
        default:
            label0.text = Num1[indexNum]
            Label1.text = Word2[indexNum]
            label3.text = Pro4[indexNum]
            label2.text = Mean3[indexNum]
            label4.text = Ex5[indexNum]
            label5.text = ExPro6[indexNum]
            label6.text = ExMean7[indexNum]
            if Detail8[indexNum] == ""{
                label7.text = "なし"
            } else {
                label7.text = Detail8[indexNum]
            }
        }
        
        
        
        
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

