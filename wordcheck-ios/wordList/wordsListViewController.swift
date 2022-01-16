import UIKit
import Alamofire
import SwiftUI

class wordsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var contentsList: [Content] = []
    var wrongList: [Content] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getList()
        setSelectButton()
    }
    
    func getList() {
        let header: HTTPHeaders = [
            "Authorization": self.token
        ]
        AF.request("http://52.78.37.13/api/words/", method: .get, headers: header).validate(statusCode: 200..<500).responseDecodable(of: [Content].self) { response in
            switch response.result {
            case .success:
                guard let list = response.value else { return }
                Storage.store(list, to: .caches, as: "contents_list.json")
                self.contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
                self.tableView.reloadData()
                
            case .failure:
                return
            }
        }
    }
    
    func getWrongList () {
        
    }
    
    func setSelectButton() {
        let content = UIAction(title: "챕터") { _ in
            // 챕터별 list 가져오기
            self.contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
            self.tableView.reloadData()
        }
        
        let wrong = UIAction(title: "틀린 횟수") { _ in
            // 틀린 횟수별 list 가져오기
            self.contentsList = self.wrongList
            self.tableView.reloadData()
        }
        
        let buttonMenu = UIMenu(title: "단어장", children: [content, wrong])
        selectButton.menu = buttonMenu
    }
    
    @IBAction func wordsCreateButton(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "wordsCreateViewController") as? wordsCreateViewController else { return }
        vc.modalTransitionStyle = .coverVertical
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension wordsListViewController: LoadCreateViewDelegate {
    func loadTableView() {
        self.contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
        self.tableView.reloadData()
    }
}

extension wordsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? WordCell else {
            return UITableViewCell()
        }
        cell.cellLabel.text = contentsList[indexPath.row].contents
        return cell
    }
    
}

extension wordsListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        
        let parameters: Parameters = [
            "contents": contentsList[indexPath.row].contents!
        ]
        
        AF.request("http://52.78.37.13/api/words/detail_list/", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<500).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard let detailList = response.value else { return }
                Storage.store(detailList, to: .caches, as: "words_detail.json")
                self.performSegue(withIdentifier: "showDetail", sender: nil)
                
            case .failure:
                return
            }
        }
    }
    
}

class WordCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
}
