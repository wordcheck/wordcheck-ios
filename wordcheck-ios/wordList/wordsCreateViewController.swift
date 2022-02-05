import UIKit
import Alamofire
import DropDown

class wordsCreateViewController: UIViewController {
    @IBOutlet weak var contentsInput: UITextField!
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UIButton!
    @IBOutlet weak var meaningInput: UITextField!
    @IBOutlet weak var contentsLength: UILabel!
    @IBOutlet weak var spellingLength: UILabel!
    weak var delegate: LoadViewDelegate?
    
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var contentsList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
    let detailList = Storage.retrive("words_detail.json", from: .caches, as: [WordsDetail].self) ?? []
    var spelling = ""
    let category = ["명사", "대명사", "동사", "부사", "형용사", "전치사", "접속사", "감탄사"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spellingInput.text = spelling
        categoryInput.layer.borderWidth = 1
        categoryInput.layer.cornerRadius = 5
        categoryInput.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    @IBAction func contentsCheck(_ sender: Any) {
        contentsLength.text = "\(contentsInput.text!.count)/20"
        limitLength(textField: contentsInput, maxLength: 20)
    }
    @IBAction func spellingCheck(_ sender: Any) {
        spellingLength.text = "\(spellingInput.text!.count)/30"
        limitLength(textField: spellingInput, maxLength: 30)
    }
    
    @IBAction func categoryClick(_ sender: Any) {
        spellingInput.resignFirstResponder()
        let dropDown = DropDown()
        dropDown.backgroundColor = UIColor.white
        dropDown.anchorView = categoryInput
        dropDown.direction = .bottom
        dropDown.dataSource = category
        dropDown.selectionAction = { [] (index: Int, item: String) in
            self.categoryInput.setTitle(item, for: .normal)
            self.categoryInput.setTitleColor(.label, for: .normal)
            self.meaningInput.becomeFirstResponder()
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
            "category": categoryInput.currentTitle!,
            "meaning": meaningInput.text!
        ]
        
        if spellingInput.text! != "" && meaningInput.text! != "" && !detailList.contains(where: { $0.spelling == spellingInput.text }) {
            AF.request("https://wordcheck.sulrae.com/api/words/", method: .post, parameters: parameters, headers: header).validate(statusCode: 200..<300).response { response in
                switch response.result {
                case .success:
                    let alert = UIAlertController(title: "알림", message: "단어 추가 성공", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default) { action in
                        let content = Content(contents: self.contentsInput.text!)
                        if !self.contentsList.contains(where: { $0 == content }) {
                            self.contentsList.append(content)
                            self.contentsList = self.contentsList.sorted(by: {$0.contents! < $1.contents!})
                        }
                        Storage.store(self.contentsList, to: .caches, as: "contents_list.json")
                        self.contentsInput.text = ""
                        self.spellingInput.text = ""
                        self.categoryInput.setTitle("품사", for: .normal)
                        self.categoryInput.titleLabel?.textColor = .systemGray3
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
        } else if detailList.contains(where: { $0.spelling == spellingInput.text && $0.category == categoryInput.currentTitle }) {
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

extension wordsCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == contentsInput {
            spellingInput.becomeFirstResponder()
        }
        return true
    }
    
    func limitLength(textField: UITextField, maxLength: Int) {
        if textField.text!.count > maxLength {
            textField.deleteBackward()
        }
    }
}
