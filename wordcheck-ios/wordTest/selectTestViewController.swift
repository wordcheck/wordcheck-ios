import UIKit
import Alamofire
import DropDown

class selectTestViewController: UIViewController {

    @IBOutlet weak var selectButton: UIButton!
    
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var contents: [Content] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doTest" {
            let vc = segue.destination as? wordsTestViewController
            if let content = sender as? String {
                vc?.content = content
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectButton(_ sender: Any) {
        contents = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
        let count = contents.count
        var test: [String] = []
        for i in 0..<count {
            guard let list = contents[i].contents else { return }
            test.append(list)
        }
        let dropDown = DropDown()
        dropDown.backgroundColor = UIColor.white
        dropDown.anchorView = selectButton
        dropDown.direction = .bottom
        dropDown.dataSource = test
        dropDown.selectionAction = { [] (index: Int, item: String) in
            // ! 로컬로 받아놓으면 굳이 통신 안해도 될듯
            let header: HTTPHeaders = [
                "Authorization": self.token
            ]
            let parameters: Parameters = [
                "contents": item
            ]
            
            AF.request("http://52.78.37.13/api/words/detail_list/", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<500).responseDecodable(of: [WordsDetail].self) { response in
                switch response.result {
                case .success:
                    guard let testList = response.value else { return }
                    Storage.store(testList, to: .caches, as: "words_test.json")
                    self.performSegue(withIdentifier: "doTest", sender: item)
                    
                case .failure:
                    return
                }
            }
        }
        dropDown.show()
    }
}
