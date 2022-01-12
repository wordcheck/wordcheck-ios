import UIKit
import Alamofire
import SwiftUI

class wordsListViewController: UIViewController {
    
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var contentsList = Storage.retrive("contents_list.json", from: .documents, as: [Content].self) ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func wordsCreateButton(_ sender: Any) {
        performSegue(withIdentifier: "createWord", sender: nil)
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
        cell.contentLabel.text = contentsList[indexPath.row].contents
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
                Storage.store(detailList, to: .documents, as: "words_detail.json")
                self.performSegue(withIdentifier: "showDetail", sender: nil)
                
            case .failure:
                return
            }
        }
    }
    
}

class WordCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
}
