import UIKit
import Alamofire

class wrongViewController: UIViewController {

    let token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    private let wrongList: [Int] = [0, 1, 2, 3, 4, 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension wrongViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wrongList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wrongCell", for: indexPath) as? WrongCell else {
            return UITableViewCell()
        }
        if indexPath.row < wrongList.count - 1 {
            cell.wrongLabel.text = "틀린 횟수 \(wrongList[indexPath.row])회"
        } else {
            cell.wrongLabel.text = "틀린 횟수 \(wrongList[indexPath.row])회 이상"
        }
        return cell
    }
}

extension wrongViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        let parameters: Parameters = [
            "wrong_count": wrongList[indexPath.row]
        ]
        
        AF.request("http://52.78.37.13/api/words/detail_list/", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard let wrongList = response.value else { return }
                Storage.store(wrongList, to: .caches, as: "wrong_detail.json")
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "wrongListViewController") as? wrongListViewController else { return }
//                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                
            case .failure:
                return
            }
        }
    }
}
class WrongCell: UITableViewCell {
    @IBOutlet weak var wrongLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
