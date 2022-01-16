import UIKit
import Alamofire
import DropDown

protocol LoadUpdateViewDelegate: AnyObject {
    func loadTableView()
}

class wordsUpdateViewController: UIViewController {
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var index: Int!
    var wordDetail = Storage.retrive("words_detail.json", from: .caches, as: [WordsDetail].self) ?? []
    
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!
    @IBOutlet weak var meaningInput: UITextField!
    weak var delegate: LoadUpdateViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spellingInput.text = wordDetail[index].spelling
        meaningInput.text = wordDetail[index].meaning
    }
    
    @IBAction func categoryClick(_ sender: Any) {
        let dropDown = DropDown()
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.anchorView = categoryInput
        dropDown.direction = .bottom
        dropDown.dataSource = ["명사", "대명사", "동사", "부사", "형용사", "전치사", "접속사", "감탄사"]
        dropDown.selectionAction = { [] (index: Int, item: String) in
            self.categoryInput.text = item
        }
        dropDown.show()
    }
    
    // ! update되면 화면 갱신되게
    @IBAction func updateButton(_ sender: Any) {
        let header: HTTPHeaders = [
            "Authorization": self.token
        ]
        let parameters: Parameters = [
            "spelling": spellingInput.text!,
            "category": categoryInput.text!,
            "meaning": meaningInput.text!
        ]
        let id = self.wordDetail[index].id!
        
        AF.request("http://52.78.37.13/api/words/\(id)/", method: .patch, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<500).responseDecodable(of: WordsUpdate.self) { response in
            switch response.result {
            case .success:
                let alert = UIAlertController(title: "알림", message: "단어 수정 성공", preferredStyle: UIAlertController.Style.alert)
                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                    self.wordDetail[self.index] = (response.value?.word)!
                    Storage.store(self.wordDetail, to: .caches, as: "words_detail.json")
                    self.delegate?.loadTableView()
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)

            case .failure:
                let alert = UIAlertController(title: "알림", message: "단어 수정 실패", preferredStyle: UIAlertController.Style.alert)
                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
}
