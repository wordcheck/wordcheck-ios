import UIKit
import Alamofire
import AVFoundation

class AnalyzeWrongWordViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var wordsCount: UILabel!
    
    private let wordsDetailUrl = "https://wordcheck.sulrae.com/api/words/detail_list/"
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    let contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
    var allList: [WordsDetail] = []
    var bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setList()
    }
    
    func setList() {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        var parameters: Parameters = [:]
        for i in 0..<contentsList.count {
            parameters = [
                "contents": contentsList[i].contents!
            ]
            AF.request(wordsDetailUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
                switch response.result {
                case .success:
                    guard var list = response.value else { return }
                    list = list.sorted(by: {$0.wrong_count! > $1.wrong_count!})
                    let countList = list.first?.wrong_count
                    list = list.filter({$0.wrong_count == countList})
                    for word in list {
                        if !self.allList.contains(word) {
                            self.allList.append(word)
                        }
                    }
                    if i == self.contentsList.count - 1 {
                        self.allList = self.allList.sorted(by: {$0.wrong_count! > $1.wrong_count!})
                        let countWrong = self.allList.first?.wrong_count
                        if countWrong == 0 {
                            self.wordsCount.text = "단어 수: 0"
                            return
                        } else {
                            self.allList = self.allList.filter({$0.wrong_count == countWrong})
                            self.tableView.reloadData()
                            self.wordsCount.text = "단어 수: \(self.allList.count)"
                        }
                    }
                case .failure:
                    return
                }
            }
        }
    }
}

extension AnalyzeWrongWordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wrongCell", for: indexPath) as? WrongCell else { return UITableViewCell() }
        cell.contentLabel.text = allList[indexPath.row].contents
        cell.spellingLabel.text = allList[indexPath.row].spelling
        cell.categoryLabel.text = allList[indexPath.row].category
        cell.meaningLabel.text = allList[indexPath.row].meaning
        cell.countLabel.text = "툴린 횟수: \(allList[indexPath.row].wrong_count!)"
        if bookMarkList.contains(where: { $0.id == self.allList[indexPath.row].id }) {
            cell.bookMarkButton.isSelected = true
            cell.bookMarkButton.tintColor = .yellowGreen
        } else {
            cell.bookMarkButton.isSelected = false
            cell.bookMarkButton.tintColor = .lightGray
        }
        cell.bookMarkButtonTapHandler = {
            cell.bookMarkButton.isSelected = !cell.bookMarkButton.isSelected
            self.allList[indexPath.row].remember = cell.bookMarkButton.isSelected
            
            if cell.bookMarkButton.isSelected == true && !self.bookMarkList.contains(self.allList[indexPath.row]) {
                self.bookMarkList.append(self.allList[indexPath.row])
                cell.bookMarkButton.tintColor = .yellowGreen
            } else if cell.bookMarkButton.isSelected == false {
                self.bookMarkList = self.bookMarkList.filter({ $0.id != self.allList[indexPath.row].id })
                cell.bookMarkButton.tintColor = .lightGray
            }
            Storage.store(self.bookMarkList, to: .documents, as: "bookmark_list.json")
        }
        cell.speechButtonTapHandler = {
            let utterance = AVSpeechUtterance(string: cell.spellingLabel.text!)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synthesizer.speak(utterance)
        }
        return cell
    }
}

extension AnalyzeWrongWordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}
