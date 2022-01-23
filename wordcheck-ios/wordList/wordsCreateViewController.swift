import UIKit
import Alamofire
import DropDown

class wordsCreateViewController: UIViewController {
    @IBOutlet weak var contentsInput: UITextField!
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!
    @IBOutlet weak var meaningInput: UITextField!
    weak var delegate: LoadViewDelegate?
    
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func categoryClick(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.backgroundColor = UIColor.white
        dropDown.anchorView = categoryInput
        dropDown.direction = .bottom
        dropDown.dataSource = ["명사", "대명사", "동사", "부사", "형용사", "전치사", "접속사", "감탄사"]
        dropDown.selectionAction = { [] (index: Int, item: String) in
            self.categoryInput.text = item
        }
        dropDown.show()
    }
    
    @IBAction func wordsCreateButton(_ sender: Any) {
        if contentsInput.text == "" {
            contentsInput.text = "그룹 미지정"
        }
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        let parameters: Parameters = [
            "contents": contentsInput.text!,
            "spelling": spellingInput.text!,
            "category": categoryInput.text!,
            "meaning": meaningInput.text!
        ]
        
        if spellingInput.text! != "" && categoryInput.text! != "" && meaningInput.text! != "" {
            AF.request("http://52.78.37.13/api/words/", method: .post, parameters: parameters, headers: header).validate(statusCode: 200..<500).response { response in
                switch response.result {
                case .success:
                    let alert = UIAlertController(title: "알림", message: "단어 추가 성공", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.contentsInput.text = ""
                        self.spellingInput.text = ""
                        self.categoryInput.text = ""
                        self.meaningInput.text = ""
                        let content = Content(contents: self.contentsInput.text!)
                        if !self.contentsList.contains(where: { $0 == content }) {
                            self.contentsList.append(content)
                        }
                        Storage.store(self.contentsList, to: .caches, as: "contents_list.json")
                        self.delegate?.loadCreateTableView()
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                    
                case .failure:
                    return
                }
            }
        } else {
            let alert = UIAlertController(title: "경고", message: "빈칸 없이 입력해주세요", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

