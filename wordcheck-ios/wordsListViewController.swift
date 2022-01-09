import UIKit
import Alamofire
import SwiftUI

// account_token 이용해서 words get
// words를 tableView로 표시

class wordsListViewController: UIViewController {
    
    var contents: [Word] = []
    
    override func viewDidLoad() {
        loadWord()
        print(contents)
        print(contents.count)
        super.viewDidLoad()
    }
    
    func loadWord() {
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWNrbmFtZSI6ImppaG8xIn0.T3oI95w17JUZ5a2DTUsMzVjLFFQwngsf7xrFWXdDfn0"
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        let wordList = AF.request("http://52.78.37.13/api/words/", method: .get, headers: header).responseJSON { response in
            switch response.result {
            case .success(let obj):
                // 단어 load 처리
                do {
                    let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let getData = try JSONDecoder().decode([Word].self, from: dataJSON)

                   // guard let content =
                    self.contents = getData
//                    print("--> \(contents.count)\n\(contents)")
                    
                } catch {
                    print(error.localizedDescription)
                }

            default:
                return
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

extension wordsListViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as? WordCell else {
            return UITableViewCell()
        }
        cell.contentLabel.text = contents[indexPath.row].contents
//                let info = viewModel.bountyInfo(at: indexPath.row)
//                cell.updateUI(info)
        return cell
    }
}

extension wordsListViewController : UITableViewDelegate {
    
}

struct Word: Codable {
    let contents: String?
}

class WordCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
}
