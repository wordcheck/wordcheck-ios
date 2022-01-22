import UIKit
import Alamofire

class wordsSearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var searchList: [WordsDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "단어 검색"
    }

}

extension wordsSearchViewController: UISearchBarDelegate {
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
        
        AF.request("http://52.78.37.13/api/words/search/", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard let list = response.value else { return }
                self.searchList = list
                self.tableView.reloadData()
                
            default:
                return
            }
        }
    }
}

extension wordsSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? ResultCell else {
            return UITableViewCell()
        }
        cell.contentLabel.text = searchList[indexPath.row].contents
        cell.spellingLabel.text = searchList[indexPath.row].spelling
        cell.categoryLabel.text = searchList[indexPath.row].category
        cell.meaningLabel.text = searchList[indexPath.row].meaning
        cell.countLabel.text = "툴린 횟수: \(searchList[indexPath.row].wrong_count ?? 0)"
        return cell
    }
    
}

class ResultCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
    }
}
