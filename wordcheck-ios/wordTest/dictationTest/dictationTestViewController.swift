import UIKit

class dictationTestViewController: UIViewController {
    @IBOutlet weak var testSpellingLabel: UILabel!
    @IBOutlet weak var testMeanLabel: UILabel!
    @IBOutlet weak var answerInput: UITextField!
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
    }
    
    func setTest() {
        answerInput.layer.borderWidth = 1
        answerInput.layer.borderColor = UIColor.systemIndigo.cgColor
        answerInput.layer.cornerRadius = 16
    }
    
    @IBAction func nextButton(_ sender: Any) {
    }
    @IBAction func resetButton(_ sender: Any) {
    }
    @IBAction func bookMarkButton(_ sender: Any) {
    }
    
}
