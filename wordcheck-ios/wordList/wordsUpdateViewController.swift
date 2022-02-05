import UIKit
import Alamofire
import DropDown

class wordsUpdateViewController: UIViewController {
    @IBOutlet weak var contentsInput: UITextField!
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UIButton!
    @IBOutlet weak var meaningInput: UITextField!
    @IBOutlet weak var contentsLength: UILabel!
    @IBOutlet weak var spellingLength: UILabel!
    weak var delegate: LoadViewDelegate?
    
    let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var index: Int!
    var detailList = Storage.retrive("words_detail.json", from: .caches, as: [WordsDetail].self) ?? []
    let category = ["명사", "대명사", "동사", "부사", "형용사", "전치사", "접속사", "감탄사"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentsInput.text = detailList[index].contents
        spellingInput.text = detailList[index].spelling
        meaningInput.text = detailList[index].meaning
        categoryInput.layer.borderWidth = 1
        categoryInput.layer.cornerRadius = 5
        categoryInput.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.traitCollection.userInterfaceStyle == .dark {
            categoryInput.backgroundColor = .black
        } else {
            categoryInput.backgroundColor = .white
        }
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
        contentsInput.resignFirstResponder()
        spellingInput.resignFirstResponder()
        meaningInput.resignFirstResponder()
        let dropDown = DropDown()
        DropDown.appearance().backgroundColor = UIColor.white
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
    
    @IBAction func updateButton(_ sender: Any) {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        let parameters: Parameters = [
            "contents": contentsInput.text!,
            "spelling": spellingInput.text!,
            "category": categoryInput.currentTitle!,
            "meaning": meaningInput.text!
        ]
        let id = self.detailList[index].id!
        
        if categoryInput.currentTitle != "품사" {
            AF.request("https://wordcheck.sulrae.com/api/words/\(id)/", method: .patch, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<500).responseDecodable(of: WordsUpdate.self) { response in
                switch response.result {
                case .success:
                    guard let word = response.value?.word else { return }
                    let alert = UIAlertController(title: "알림", message: "단어 수정 성공", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default) { action in
                        self.detailList[self.index] = word
                        Storage.store(self.detailList, to: .caches, as: "words_detail.json")
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
        } else {
            let alert = UIAlertController(title: "알림", message: "품사를 선택해주세요", preferredStyle: .alert)
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

extension wordsUpdateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == contentsInput {
            spellingInput.becomeFirstResponder()
        } else if textField == spellingInput {
            categoryClick(0)
        }
        return true
    }
    
    func limitLength(textField: UITextField, maxLength: Int) {
        if textField.text!.count > maxLength {
            textField.deleteBackward()
        }
    }
}
