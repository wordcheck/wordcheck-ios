import UIKit
import Alamofire

class selectFourTestViewController: UIViewController {
    @IBOutlet weak var testSpellingLabel: UILabel!
    @IBOutlet weak var testMeanLabel: UILabel!
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer3: UIButton!
    @IBOutlet weak var answer4: UIButton!
    
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var content = ""
    let testList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
    
    var showList: [WordsDetail] = []
    var correctList: [WordsDetail] = []
    var wrongList: [WordsDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = content
        showList = testList
        testMeanLabel.isHidden = true
        testSpellingLabel.text = showList.first?.spelling
        testMeanLabel.text = showList.first?.meaning
        setTest()
    }

    func setTest() {
        answer1.layer.borderWidth = 1
        answer2.layer.borderWidth = 1
        answer3.layer.borderWidth = 1
        answer4.layer.borderWidth = 1
        
        answer1.layer.borderColor = UIColor.lightGray.cgColor
        answer2.layer.borderColor = UIColor.lightGray.cgColor
        answer3.layer.borderColor = UIColor.lightGray.cgColor
        answer4.layer.borderColor = UIColor.lightGray.cgColor
        
        answer1.layer.cornerRadius = 16
        answer2.layer.cornerRadius = 16
        answer3.layer.cornerRadius = 16
        answer4.layer.cornerRadius = 16
        
        answer1.frame.size.width = UIScreen.main.bounds.width / 3
    }
    
    @IBAction func nextWordButton(_ sender: Any) {
        testMeanLabel.isHidden = true
        if showList.count > 1 {
            showList.removeFirst()
            testSpellingLabel.text = showList.first?.spelling
            testMeanLabel.text = showList.first?.meaning
        } else {
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
        showList = testList
        testMeanLabel.isHidden = true
        testSpellingLabel.text = showList.first?.spelling
        testMeanLabel.text = showList.first?.meaning
    }
    
    @IBAction func select1(_ sender: Any) {
        testMeanLabel.isHidden = false
    }
    @IBAction func select2(_ sender: Any) {
        testMeanLabel.isHidden = false
    }
    @IBAction func select3(_ sender: Any) {
        testMeanLabel.isHidden = false
    }
    @IBAction func select4(_ sender: Any) {
        testMeanLabel.isHidden = false
    }
}

