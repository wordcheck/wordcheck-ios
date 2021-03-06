import UIKit
import Alamofire
import AVFoundation

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let searchUrl = "https://wordcheck.sulrae.com/api/words/search/"
    let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var searchList: [WordsDetail] = []
    var bookMarkList: [WordsDetail] = []
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "단어 검색"
    }

    @IBAction func touchView(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UISearchBarDelegate {
    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else { return }
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        let parameters: Parameters = [
            "target": searchTerm
        ]
        
        AF.request(searchUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard let list = response.value else { return }
                self.bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
                self.searchList = list.sorted(by: {$0.contents! < $1.contents!})
                self.tableView.reloadData()
                if list.count == 0 {
                    let alert = UIAlertController(title: "알림", message: "검색 결과가 없습니다", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                return
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? ResultCell else { return UITableViewCell() }
        cell.contentLabel.text = searchList[indexPath.row].contents
        cell.spellingLabel.text = searchList[indexPath.row].spelling
        cell.categoryLabel.text = searchList[indexPath.row].category
        cell.meaningLabel.text = searchList[indexPath.row].meaning
        cell.countLabel.text = "툴린 횟수: \(searchList[indexPath.row].wrong_count ?? 0)"
        
        if bookMarkList.contains(where: { $0.id == self.searchList[indexPath.row].id }) {
            cell.bookMarkButton.isSelected = true
            cell.bookMarkButton.tintColor = .yellowGreen
        } else {
            cell.bookMarkButton.isSelected = false
            cell.bookMarkButton.tintColor = .lightGray
        }
        cell.bookMarkButtonTapHandler = {
            cell.bookMarkButton.isSelected = !cell.bookMarkButton.isSelected
            if cell.bookMarkButton.isSelected == true && !self.bookMarkList.contains(self.searchList[indexPath.row]) {
                self.bookMarkList.append(self.searchList[indexPath.row])
                cell.bookMarkButton.tintColor = .yellowGreen
            } else if cell.bookMarkButton.isSelected == false {
                self.bookMarkList = self.bookMarkList.filter({ $0.id != self.searchList[indexPath.row].id })
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

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}


