import UIKit
import Alamofire
import DropDown

class wordsUpdateViewController: UIViewController {
    @IBOutlet weak var contentsInput: UITextField!
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!
    @IBOutlet weak var meaningInput: UITextField!
    weak var delegate: LoadViewDelegate?
    
    let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var index: Int!
    var wordDetail = Storage.retrive("words_detail.json", from: .caches, as: [WordsDetail].self) ?? []
    let category = ["명사", "대명사", "동사", "부사", "형용사", "전치사", "접속사", "감탄사"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentsInput.text = wordDetail[index].contents
        spellingInput.text = wordDetail[index].spelling
        meaningInput.text = wordDetail[index].meaning
    }
    
    @IBAction func categoryClick(_ sender: Any) {
        let dropDown = DropDown()
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.anchorView = categoryInput
        dropDown.direction = .bottom
        dropDown.dataSource = category
        dropDown.selectionAction = { [] (index: Int, item: String) in
            self.categoryInput.text = item
        }
        dropDown.show()
    }
    @IBAction func categoryCheck(_ sender: Any) {
        if !category.contains(categoryInput.text ?? "") {
            categoryInput.text = ""
        }
    }
    
    @IBAction func updateButton(_ sender: Any) {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        let parameters: Parameters = [
            "contents": contentsInput.text!,
            "spelling": spellingInput.text!,
            "category": categoryInput.text!,
            "meaning": meaningInput.text!
        ]
        let id = self.wordDetail[index].id!
        
        AF.request("https://wordcheck.sulrae.com/api/words/\(id)/", method: .patch, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<500).responseDecodable(of: WordsUpdate.self) { response in
            switch response.result {
            case .success:
                guard let word = response.value?.word else { return }
                let alert = UIAlertController(title: "알림", message: "단어 수정 성공", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default) { action in
                    self.wordDetail[self.index] = word
                    Storage.store(self.wordDetail, to: .caches, as: "words_detail.json")
                    self.delegate?.loadUpdateTableView()
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)

            case .failure:
                let alert = UIAlertController(title: "알림", message: "단어 수정 실패", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func touchView(_ sender: Any) {
        contentsInput.resignFirstResponder()
        spellingInput.resignFirstResponder()
        categoryInput.resignFirstResponder()
        meaningInput.resignFirstResponder()
    }
}
