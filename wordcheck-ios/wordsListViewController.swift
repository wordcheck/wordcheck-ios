import UIKit
import Alamofire
import SwiftUI

class wordsListViewController: UIViewController {
    
    var contentsList: [Words] = []

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // DetailViewController 데이터 줄꺼에요
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func wordsListAddButton(_ sender: Any) {
        // 목차 추가
    }
    
    @IBAction func wordsCreateButton(_ sender: Any) {
        performSegue(withIdentifier: "createWord", sender: nil)
    }
    
}

extension wordsListViewController: UITableViewDataSource {
    
    func loadWords() {
        
    }
    
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
    // 단어 클릭하면 detail list 보여주기
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let header: HTTPHeaders = [
            // 토큰은 로컬로 처리하기
            "Authorization": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWNrbmFtZSI6ImppaG8xIn0.T3oI95w17JUZ5a2DTUsMzVjLFFQwngsf7xrFWXdDfn0"
        ]
        
        let parameters: Parameters = [
            "contents": contentsList[indexPath.row].contents!
        ]
        AF.request("http://52.78.37.13/api/words/detail_list/", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).responseJSON { response in
            switch response.result {
            case .success(let obj):
                // 단어 처리
                do {
                    // todo - [WordsDetail] parsing 처리 !
                    let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let getData = try JSONDecoder().decode([WordsDetail].self, from: dataJSON)
                    self.performSegue(withIdentifier: "showDetail", sender: getData)
                } catch {
                    print(error.localizedDescription)
                }

            default:
                return
            }
        }
    }
    
}

class WordCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
}
