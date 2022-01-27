import UIKit
import Alamofire
import SwiftUI

class wordsListViewController: UIViewController {
    @IBOutlet weak var contentButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let contentUrl = "http://52.78.37.13/api/words/"
    private let wordsDetailUrl = "http://52.78.37.13/api/words/detail_list/"
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    
    var contentsList: [Content] = []
    let wrongList: [Content] = [
        Content(contents: "0회"),
        Content(contents: "1회"),
        Content(contents: "2회"),
        Content(contents: "3회"),
        Content(contents: "4회"),
        Content(contents: "5회 이상")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
        getList()
    }
    
    func setContent() {
        let normal = UIAction(title: "그룹별") { _ in
            self.contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
            self.tableView.reloadData()
        }
        let wrong = UIAction(title: "틀린 횟수별") { _ in
            self.contentsList = self.wrongList
            self.tableView.reloadData()
        }
        let buttonMenu = UIMenu(title: "보기 선택", children: [normal, wrong])
        contentButton.menu = buttonMenu
    }
    
    func getList() {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        AF.request(contentUrl, method: .get, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [Content].self) { response in
            switch response.result {
            case .success:
                guard let list = response.value else { return }
                self.contentsList = list.sorted(by: {$0.contents! < $1.contents!})
                Storage.store(list, to: .caches, as: "contents_list.json")
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? WordCell else { return UITableViewCell() }
        cell.cellLabel.text = contentsList[indexPath.row].contents
        return cell
    }
}

extension wordsListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        var parameters: Parameters = [:]
        if self.contentButton.currentTitle != "틀린 횟수별" {
            parameters = [
                "contents": contentsList[indexPath.row].contents!
            ]
        } else {
            parameters = [
                "wrong_count": indexPath.row
            ]
        }
        AF.request(wordsDetailUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard var detailList = response.value else { return }
                detailList = detailList.sorted(by: {$0.spelling! < $1.spelling!})
                Storage.store(detailList, to: .caches, as: "words_detail.json")
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "wordsDetailListViewController") as? wordsDetailListViewController else { return }
                vc.delegate = self
                self.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            case .failure:
                return
            }
        }
    }
}

class WordCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 16
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40))
    }
}
