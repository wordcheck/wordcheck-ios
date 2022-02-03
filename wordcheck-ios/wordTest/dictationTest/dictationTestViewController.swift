import UIKit
import DropDown
import Alamofire

class dictationTestViewController: UIViewController {
    @IBOutlet weak var testSpellingLabel: UILabel!
    @IBOutlet weak var testMeanLabel: UILabel!
    @IBOutlet weak var answerInput: UITextField!
    @IBOutlet weak var answerInputBottom: NSLayoutConstraint!
    @IBOutlet weak var buttonBottom: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bookMarkButton: UIButton!
    
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var content = ""
    let testList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
    var bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
    
    var showList: [WordsDetail] = []
    var correctList: [WordsDetail] = []
    var wrongList: [WordsDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = content
        setTest()
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setTest() {
        answerInput.layer.borderWidth = 1
        answerInput.layer.borderColor = UIColor.systemIndigo.cgColor
        answerInput.layer.cornerRadius = 16
        
        testMeanLabel.isHidden = true
        
        showList = testList
        testSpellingLabel.text = showList.first?.spelling
        testMeanLabel.text = showList.first?.meaning
        testMeanLabel.isHidden = true
        
        if bookMarkList.contains(showList.first!) {
            bookMarkButton.isSelected = true
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        if testMeanLabel.isHidden == true {
            let alert = UIAlertController(title: "알림", message: "정답을 입력해주세요", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            return
        }
        testMeanLabel.isHidden = true
        answerInput.text = ""
        answerInput.layer.borderColor = UIColor.systemIndigo.cgColor
        
        if showList.count > 1 {
            showList.removeFirst()
            testSpellingLabel.text = showList.first?.spelling
            testMeanLabel.text = showList.first?.meaning
            if bookMarkList.contains(showList.first!) {
                bookMarkButton.isSelected = true
            } else {
                bookMarkButton.isSelected = false
            }
        } else {
            testMeanLabel.isHidden = false
            nextButton.isEnabled = false
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "testResult") as? testResultViewController else { return }
            vc.modalTransitionStyle = .coverVertical
            vc.correctList = self.correctList
            vc.wrongList = self.wrongList
            self.correctList = []
            self.wrongList = []
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func resetButton(_ sender: Any) {
        nextButton.isEnabled = true
        correctList = []
        wrongList = []
        setTest()
    }
    
    @IBAction func bookMarkButton(_ sender: Any) {
        bookMarkButton.isSelected = !bookMarkButton.isSelected
        if bookMarkButton.isSelected == true && !bookMarkList.contains(showList.first!) {
            bookMarkList.append(showList.first!)
            Storage.store(bookMarkList, to: .documents, as: "bookmark_list.json")
        } else if bookMarkButton.isSelected == false {
            bookMarkList = bookMarkList.filter{ $0 != showList.first! }
            Storage.store(bookMarkList, to: .documents, as: "bookmark_list.json")
        }
    }

    @IBAction func touchView(_ sender: Any) {
        answerInput.resignFirstResponder()
    }
}

extension dictationTestViewController: UITextFieldDelegate {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if noti.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
            answerInputBottom.constant = adjustmentHeight
            buttonBottom.constant = answerInputBottom.constant + answerInput.frame.height + 20
        } else {
            answerInputBottom.constant = 120
            buttonBottom.constant = 370
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        answerInput.resignFirstResponder()
        if answerInput.text?.count == 0 {
            print("한 글자 이상 입력")
            return false
        }
        if testMeanLabel.isHidden == true {
            if answerInput.text == showList.first!.meaning {
                answerInput.layer.borderColor = UIColor.green.cgColor
                testMeanLabel.isHidden = false
                correctList.append(showList.first!)
            } else {
                answerInput.layer.borderColor = UIColor.red.cgColor
                testMeanLabel.isHidden = false
                wrongList.append(showList.first!)
            }
        }
        return true
    }
}
