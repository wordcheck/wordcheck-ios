import UIKit
import Alamofire

class wrongListViewController: UIViewController {
    
    let token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    let wrongList = Storage.retrive("wrong_detail.json", from: .caches, as: [WordsDetail].self) ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension wrongListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wrongList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wrongDetailCell", for: indexPath) as? WrongDetailCell else {
            return UITableViewCell()
        }
        cell.spellingLabel.text = wrongList[indexPath.row].spelling
        cell.categoryLabel.text = wrongList[indexPath.row].category
        cell.meaningLabel.text = wrongList[indexPath.row].meaning
        
        return cell
    }
}

class WrongDetailCell: UITableViewCell {
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
}
