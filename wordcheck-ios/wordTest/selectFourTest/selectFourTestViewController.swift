import UIKit
import Alamofire

class selectFourTestViewController: UIViewController {
    @IBOutlet weak var testSpellingLabel: UILabel!
    @IBOutlet weak var testMeanLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bookMarkButton: UIButton!
    @IBOutlet weak var answer1: UILabel!
    @IBOutlet weak var answer2: UILabel!
    @IBOutlet weak var answer3: UILabel!
    @IBOutlet weak var answer4: UILabel!
    
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var content = ""
    let testList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
    var bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
    
    var showList: [WordsDetail] = []
    var correctList: [WordsDetail] = []
    var wrongList: [WordsDetail] = []
    
    var quiz: [WordsDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = content
        setTest()
    }
    
    func setTest() {
        showList = testList
        showList.shuffle()
        testMeanLabel.isHidden = true
        testSpellingLabel.text = showList.first!.spelling
        testMeanLabel.text = showList.first!.meaning
        
        if bookMarkList.contains(showList.first!) {
            bookMarkButton.isSelected = true
        }
        
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
        
        quizSet()
    }
    
    func quizSet() {
        quiz = []
        quiz.append(showList.first!)
        let target = testList.filter( { $0 != showList.first } )
        while quiz.count < 4 {
            let word = target.randomElement()!
            if !quiz.contains(word) {
                quiz.append(word)
            }
        }
        quiz = quiz.shuffled()
        answer1.text = quiz[0].meaning
        answer2.text = quiz[1].meaning
        answer3.text = quiz[2].meaning
        answer4.text = quiz[3].meaning
        
        answer1.isUserInteractionEnabled = true
        answer2.isUserInteractionEnabled = true
        answer3.isUserInteractionEnabled = true
        answer4.isUserInteractionEnabled = true
        
        let clickAnswer1 = UITapGestureRecognizer(target: self, action: #selector(select1))
        let clickAnswer2 = UITapGestureRecognizer(target: self, action: #selector(select2))
        let clickAnswer3 = UITapGestureRecognizer(target: self, action: #selector(select3))
        let clickAnswer4 = UITapGestureRecognizer(target: self, action: #selector(select4))
        
        answer1.addGestureRecognizer(clickAnswer1)
        answer2.addGestureRecognizer(clickAnswer2)
        answer3.addGestureRecognizer(clickAnswer3)
        answer4.addGestureRecognizer(clickAnswer4)
    }
    
    func quizSolve(_ label: UILabel, _ index: Int) {
        if quiz[index].id == showList.first?.id {
            label.layer.borderColor = UIColor.green.cgColor
            correctList.append(showList.first!)
        } else {
            label.layer.borderColor = UIColor.red.cgColor
            wrongList.append(showList.first!)
        }
    }
    
    @IBAction func nextWordButton(_ sender: Any) {
        if testMeanLabel.isHidden == true {
            let alert = UIAlertController(title: "알림", message: "정답을 골라주세요", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
            return
        }
        testMeanLabel.isHidden = true
        
        answer1.layer.borderColor = UIColor.lightGray.cgColor
        answer2.layer.borderColor = UIColor.lightGray.cgColor
        answer3.layer.borderColor = UIColor.lightGray.cgColor
        answer4.layer.borderColor = UIColor.lightGray.cgColor
        
        if showList.count > 1 {
            showList.removeFirst()
            testSpellingLabel.text = showList.first?.spelling
            testMeanLabel.text = showList.first?.meaning
            if bookMarkList.contains(showList.first!) {
                bookMarkButton.isSelected = true
            } else {
                bookMarkButton.isSelected = false
            }
            quizSet()
            
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
        
        answer1.layer.borderColor = UIColor.lightGray.cgColor
        answer2.layer.borderColor = UIColor.lightGray.cgColor
        answer3.layer.borderColor = UIColor.lightGray.cgColor
        answer4.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @objc func select1(sender: UITapGestureRecognizer) {
        if testMeanLabel.isHidden == true { quizSolve(answer1, 0) }
        testMeanLabel.isHidden = false
    }
    @objc func select2(sender: UITapGestureRecognizer) {
        if testMeanLabel.isHidden == true { quizSolve(answer2, 1) }
        testMeanLabel.isHidden = false
    }
    @objc func select3(sender: UITapGestureRecognizer) {
        if testMeanLabel.isHidden == true { quizSolve(answer3, 2) }
        testMeanLabel.isHidden = false
    }
    @objc func select4(sender: UITapGestureRecognizer) {
        if testMeanLabel.isHidden == true { quizSolve(answer4, 3) }
        testMeanLabel.isHidden = false
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
}

