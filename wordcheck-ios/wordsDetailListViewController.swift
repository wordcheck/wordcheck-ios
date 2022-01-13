import UIKit
import SwiftUI
import Alamofire

class wordsDetailListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var detailList = Storage.retrive("words_detail.json", from: .caches, as: [WordsDetail].self) ?? []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateWord" {
            let vc = segue.destination as? wordsUpdateViewController
            if let index = sender as? Int {
                vc?.index = index
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        cell.updateButtonTapHandler = {
            self.performSegue(withIdentifier: "updateWord", sender: indexPath.row)
        }
        
        cell.deleteButtonTapHandler = {
            let header: HTTPHeaders = [
                "Authorization": self.token
            ]
            let id = self.detailList[indexPath.row].id!

            AF.request("http://52.78.37.13/api/words/\(id)/", method: .delete, headers: header).validate(statusCode: 200..<500).response { response in
                switch response.result {
                case .success:
                    let alert = UIAlertController(title: "알림", message: "단어 삭제 성공", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.detailList = self.detailList.filter { $0.id != id }
                //        if let index = detailList.firstIndex(of: WordsDetail) {
                //            detailList.remove(at: index)
                //        }
                        Storage.store(self.detailList, to: .caches, as: "words_detail.json")
                        self.tableView.reloadData()
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)

                case .failure:
                    return
                }
            }
        }
        return cell
    }
    
}

extension wordsDetailListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print("[\(detailList[indexPath.row].id)]")
    }
}


class DetailCell: UITableViewCell {
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    
    var updateButtonTapHandler: (() -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
    @IBAction func updateButton(_ sender: Any) {
        updateButtonTapHandler?()
    }

    @IBAction func deleteButton(_ sender: Any) {
        deleteButtonTapHandler?()
    }
}
