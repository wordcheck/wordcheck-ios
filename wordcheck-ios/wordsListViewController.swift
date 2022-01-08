import UIKit
import Alamofire
import SwiftUI

// account_token 이용해서 words get
// words를 tableView로 표시

class wordsListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadWord() {
        let token = "access_token"
        let header: HTTPHeaders = [
            "Authorization": token,
        ]
        let wordList = AF.request("http://52.78.37.13/api/words/", method: .get, headers: header).validate(statusCode: 200..<300).responseJSON { response in
            // 단어 load 처리
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

extension wordsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as? WordCell else {
            return UITableViewCell()
        }
        
//        let info = viewModel.bountyInfo(at: indexPath.row)
//        cell.updateUI(info)
        return cell
    }
}

extension wordsListViewController : UITableViewDelegate {
    
}


struct Word: Codable {
    let contents: [String]?
}


class WordCell: UITableViewCell {
    
}
