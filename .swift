//
//  ViewController.swift
//  Study Chinese app
//
//  Created by Kosuke Shigematsu on 4/29/23.
//

import UIKit

var whole:[String] = []
var counter = 0
var part:[String] = []
var counter2 = 0
var selected:[String] = []
var Num1:[String] = []
var Word2:[String] = []
var Mean3:[String] = []
var Pro4:[String] = []
var Ex5:[String] = []
var ExPro6:[String] = []
var ExMean7:[String] = []
var Detail8:[String] = []
var indexNum = 0

class ViewController: UIViewController,UITabBarDelegate,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Word2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        cell.NumLabel.text = Num1[indexPath.row]
        cell.WordLabel.text = Word2[indexPath.row]
        if 700 <= indexPath.row  {
            cell.NumLabel.backgroundColor = .red
        } else if 300 <= indexPath.row  && indexPath.row < 700{
            cell.NumLabel.backgroundColor = .green
        } else if 0 <= indexPath.row && indexPath.row < 300{
            cell.NumLabel.backgroundColor = .systemBlue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexNum = indexPath.row
        print("今押されました,\(indexNum)")
        if let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") {
            show(destinationViewController, sender: nil)

        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil),forCellReuseIdentifier: "tableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
               tableView.estimatedRowHeight = 100
        indexNum = Int.random(in: 0..<394)
        whole = loadCSV(fileName: "中国語　処理後")
        counter2 = whole.count
        for _ in 0...counter2-1{
            part = whole[counter].components(separatedBy: ",")
            selected += part//全部を回収
            Num1.append(part[0])
            Word2.append(part[1])
            Mean3.append(part[2])
            Pro4.append(part[3])
            Ex5.append(part[4])
            ExPro6.append(part[5])
            ExMean7.append(part[6])
            Detail8.append(part[7])
            whole.removeFirst()
            
        }
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            // セルの高さを決定するロジックを実装する
            // 例えば、indexPath.rowに基づいてセルごとに異なる高さを返すことができます
            if indexPath.row == 0 {
                return 100 // インデックスパスが0のセルの高さを60に設定
            } else {
                return 100 // それ以外のセルの高さを44に設定
            }
        }
    
    func loadCSV(fileName: String) -> [String] {
        var dataArray: [String] = []
        if let csvBundle = Bundle.main.path(forResource: fileName, ofType: "csv") {
            do {
                let csvData = try String(contentsOfFile: csvBundle,encoding: .utf8)
                dataArray = csvData.components(separatedBy: "\n")
                dataArray.removeLast()
            } catch {
                print("エラー")
            }
        }
        return dataArray
    }
}

