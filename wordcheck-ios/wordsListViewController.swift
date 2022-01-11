import UIKit
import Alamofire
import SwiftUI

class wordsListViewController: UIViewController {
    
    var contentsList: [Words] = []

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let vc = segue.destination as? wordsDetailListViewController
            if let detail = sender as? [WordsDetail] {
                vc?.detailList = detail
            }
        }
    }
    
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
            // ! 토큰은 로컬로 처리하기
            "Authorization": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWNrbmFtZSI6ImppaG8xIn0.T3oI95w17JUZ5a2DTUsMzVjLFFQwngsf7xrFWXdDfn0"
        ]
        
        let parameters: Parameters = [
            "contents": contentsList[indexPath.row].contents!
        ]
        
        AF.request("http://52.78.37.13/api/words/detail_list/", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<500).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard let detailList = response.value else { return }
                self.performSegue(withIdentifier: "showDetail", sender: detailList)
                
            case .failure:
                return
            }
        }
    }
    
}

class WordCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
}
