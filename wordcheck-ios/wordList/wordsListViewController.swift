import UIKit
import Alamofire
import SwiftUI

class wordsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var contentsList: [Content] = []
    var wrongList: [Content] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "챕터"
        getList()
    }
    
    func getList() {
        let header: HTTPHeaders = [
            "Authorization": self.token
        ]
        AF.request("http://52.78.37.13/api/words/", method: .get, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [Content].self) { response in
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
        // 틀린 횟수 querystring으로 보내서 list 받아옴
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        
        let parameters: Parameters = [
            "wrong_count": 0
        ]
        
        AF.request("http://52.78.37.13/api/words/detail_list/", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard let wrongList = response.value else { return }
                Storage.store(wrongList, to: .caches, as: "wrong_list.json")
                self.tableView.reloadData()
                
            case .failure:
                return
            }
        }
    }
    
    @IBAction func wordsCreateButton(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "wordsCreateViewController") as? wordsCreateViewController else { return }
        vc.modalTransitionStyle = .coverVertical
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension wordsListViewController: LoadViewDelegate {
    func loadCreateTableView() {
        self.contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
        self.tableView.reloadData()
    }
    func loadUpdateTableView() {}
    func loadDeleteTableView() {
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
        
        AF.request("http://52.78.37.13/api/words/detail_list/", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard let detailList = response.value else { return }
                Storage.store(detailList, to: .caches, as: "words_detail.json")
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "wordsDetailListViewController") as? wordsDetailListViewController else { return }
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                
            case .failure:
                return
            }
        }
    }
    
}

class WordCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
}
