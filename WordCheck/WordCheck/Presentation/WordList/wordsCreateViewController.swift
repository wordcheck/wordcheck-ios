import UIKit
import Alamofire
import DropDown

class wordsCreateViewController: UIViewController {
    @IBOutlet weak var contentsInput: UITextField!
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!
    @IBOutlet weak var meaningInput: UITextField!
    weak var delegate: LoadViewDelegate?
    
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
    let detailList = Storage.retrive("words_detail.json", from: .caches, as: [WordsDetail].self) ?? []
    var spelling = ""
    let category = ["명사", "대명사", "동사", "부사", "형용사", "전치사", "접속사", "감탄사"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spellingInput.text = spelling
    }
    
    @IBAction func categoryClick(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.backgroundColor = UIColor.white
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
    
    @IBAction func wordsCreateButton(_ sender: Any) {
        if contentsInput.text == "" {
            contentsInput.text = "그룹 미지정"
        }
        spelling = spellingInput.text!
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        let parameters: Parameters = [
            "contents": contentsInput.text!,
            "spelling": spelling,
            "category": categoryInput.text!,
            "meaning": meaningInput.text!
        ]
        
        if spellingInput.text! != "" && categoryInput.text! != "" && meaningInput.text! != "" && !detailList.contains(where: { $0.spelling == spellingInput.text }) {
            AF.request("https://wordcheck.sulrae.com/api/words/", method: .post, parameters: parameters, headers: header).validate(statusCode: 200..<300).response { response in
                switch response.result {
                case .success:
                    let alert = UIAlertController(title: "알림", message: "단어 추가 성공", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        let content = Content(contents: self.contentsInput.text!)
                        if !self.contentsList.contains(where: { $0 == content }) {
                            self.contentsList.append(content)
                            self.contentsList = self.contentsList.sorted(by: {$0.contents! < $1.contents!})
                        }
                        Storage.store(self.contentsList, to: .caches, as: "contents_list.json")
                        self.contentsInput.text = ""
                        self.spellingInput.text = ""
                        self.categoryInput.text = ""
                        self.meaningInput.text = ""
                        self.delegate?.loadCreateTableView()
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                    
                case .failure:
                    let alert = UIAlertController(title: "알림", message: "오류", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if detailList.contains(where: { $0.spelling == spellingInput.text}) {
            let alert = UIAlertController(title: "경고", message: "중복된 단어입니다", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "경고", message: "빈칸 없이 입력해주세요", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func touchView(_ sender: Any) {
        contentsInput.resignFirstResponder()
        spellingInput.resignFirstResponder()
        categoryInput.resignFirstResponder()
        meaningInput.resignFirstResponder()
    }
}

