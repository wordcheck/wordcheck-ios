import UIKit
import Alamofire

class ContentsViewController: UIViewController {
    @IBOutlet weak var contentButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let contentUrl = "https://wordcheck.sulrae.com/api/words/"
    private let wordsDetailUrl = "https://wordcheck.sulrae.com/api/words/detail_list/"
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    
    var contentsList: [Content] = []
    var wrongList: [Content] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
        getList()
    }
    
    func setContent() {
        contentsList = []
        let normal = UIAction(title: "그룹별") { _ in
            self.contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
            self.contentsList = self.contentsList.sorted(by: {$0.contents! < $1.contents!})
            self.contentButton.setTitle("그룹별", for: .normal)
            self.tableView.reloadData()
        }
        let wrong = UIAction(title: "틀린 횟수별") { _ in
            self.contentsList = Storage.retrive("wrong_content.json", from: .caches, as: [Content].self) ?? []
            self.contentsList = self.contentsList.sorted(by: {$0.contents! < $1.contents!})
            self.contentButton.setTitle("틀린 횟수별", for: .normal)
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
                self.setWrongList()
                if self.contentsList.count == 0 {
                    let alert = UIAlertController(title: "알림", message: "단어가 없습니다 단어를 추가해주세요", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            case .failure:
                return
            }
        }
    }
    
    func setWrongList() {
        wrongList = []
        var wrongCount: [Int] = []
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        var parameters: Parameters = [:]
        if self.contentButton.currentTitle != "틀린 횟수별" {
            for i in 0..<contentsList.count {
                parameters = [
                    "contents": contentsList[i].contents!
                ]
                AF.request(wordsDetailUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
                    switch response.result {
                    case .success:
                        guard let detailList = response.value else { return }
                        for i in 0..<detailList.count {
                            if !wrongCount.contains(detailList[i].wrong_count ?? 0) {
                                wrongCount.append(detailList[i].wrong_count ?? 0)
                            }
                        }
                        wrongCount = wrongCount.sorted(by: {$0 < $1})
                        for i in 0..<wrongCount.count {
                            if !self.wrongList.contains(Content(contents: "\(wrongCount[i])회")) {
                                self.wrongList.append(Content(contents: "\(wrongCount[i])회"))
                            }
                        }
                        self.wrongList = self.wrongList.sorted(by: {$0.contents! < $1.contents!})
                        Storage.store(self.wrongList, to: .caches, as: "wrong_content.json")
                    case .failure:
                        return
                    }
                }
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

extension ContentsViewController: LoadViewDelegate {
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

extension ContentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? ContentCell else { return UITableViewCell() }
        cell.cellLabel.text = contentsList[indexPath.row].contents
        return cell
    }
}

extension ContentsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
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
            let wrongCount = wrongList[indexPath.row].contents!.split(separator: "회")
            parameters = [
                "wrong_count": wrongCount[0]
            ]
        }
        AF.request(wordsDetailUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard var detailList = response.value else { return }
                detailList = detailList.sorted(by: {$0.spelling! < $1.spelling!})
                Storage.store(detailList, to: .caches, as: "words_detail.json")
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "wordsDetailListViewController") as? WordListViewController else { return }
                vc.delegate = self
                vc.contentName = self.contentsList[indexPath.row].contents!
                self.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            case .failure:
                return
            }
        }
    }
}
