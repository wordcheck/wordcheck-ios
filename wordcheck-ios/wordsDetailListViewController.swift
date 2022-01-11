import UIKit
import SwiftUI
import Alamofire

class wordsDetailListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var detailList: [WordsDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

extension wordsDetailListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath) as? DetailCell else {
            return UITableViewCell()
        }
        cell.spellingLabel.text = self.detailList[indexPath.row].spelling
        cell.categoryLabel.text = self.detailList[indexPath.row].category
        cell.meaningLabel.text = self.detailList[indexPath.row].meaning
        
        // delete api, ! 지우면 갱신되게 하기
        cell.deleteButtonTapHandler = {
            let header: HTTPHeaders = [
                "Authorization": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWNrbmFtZSI6ImppaG8xIn0.T3oI95w17JUZ5a2DTUsMzVjLFFQwngsf7xrFWXdDfn0"
            ]
            
            let id = self.detailList[indexPath.row].id!
            AF.request("http://52.78.37.13/api/words/\(id)/", method: .delete, headers: header).responseJSON { response in
                switch response.result {
                case .success:
                    let alert = UIAlertController(title: "알림", message: "단어 삭제 성공", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.tableView.reloadData()
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                default:
                    return
                }
            }
        }
        
        return cell
    }
    
    
}

extension wordsDetailListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //print("--> [\(indexPath.row)] \(self.detailList[indexPath.row])")
    }
}

class DetailCell: UITableViewCell {
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    
    var deleteButtonTapHandler: (() -> Void)?
    
    @IBAction func deleteButton(_ sender: Any) {
        deleteButtonTapHandler?()
    }
}
