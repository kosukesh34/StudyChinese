import UIKit

class AViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableViewのデリゲートとデータソースを設定
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ATableViewCell", bundle: nil),forCellReuseIdentifier: "AtableViewCell")
    }

    // TableViewのセルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // 例として10個のセルを表示する場合
    }

    // TableViewのセルの内容を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AtableViewCell", for: indexPath) as! ATableViewCell
        cell.NumLabel.text = "1"
        cell.TextLabel.text = "This is a text"
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexNum = indexPath.row
        print("今押されました,\(indexNum)")
        performSegue(withIdentifier: "toTab", sender: nil)
    }
}
