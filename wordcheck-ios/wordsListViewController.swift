import UIKit
import Alamofire
import SwiftUI

// account_token 이용해서 words get
// words를 tableView로 표시

class wordsListViewController: UIViewController {
    
    //var accountToken: String = ""
    var contentsList: [Words] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension wordsListViewController: UITableViewDataSource {
    
    func loadWords() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath) as? WordCell else {
            return UITableViewCell()
        }
        cell.contentLabel.text = contentsList[indexPath.row].contents
        return cell
    }
    
}

extension wordsListViewController : UITableViewDelegate {
    
}

struct Words: Codable {
    let contents: String?
}

class WordCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
}
