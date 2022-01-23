import UIKit
import Alamofire
import SwiftUI

class wordsTestViewController: UIViewController {
    var content = ""
    let token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    let testList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
    var wordData: [WordCard] = []
    var stackContainer: StackContainerView!
    let testView = TestView()
    
    //MARK: - Init
    override func loadView() {
        view = testView
        view.backgroundColor = .systemBackground
        
        stackContainer = StackContainerView()
        view.addSubview(stackContainer)
        configureStackContainer()
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        configureNavigationBarButtonItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = content
        // ! 좀 더 좋은 방법 찾아보기
        for i in 0..<testList.count {
            guard let id = testList[i].id, let spell = testList[i].spelling, let cate = testList[i].category, let mean = testList[i].meaning else { return }
            wordData.append(WordCard(id: id, spelling: spell, category: cate, meaning: mean))
        }
        stackContainer.dataSource = self
        
        testView.correctButtonTapHandler = {
            let index = self.stackContainer.cardViews.count - self.stackContainer.visibleCards.count
            if index < self.stackContainer.cardViews.count {
                self.stackContainer.swipeDidEnd(on: (self.stackContainer.cardViews[index]))
                self.stackContainer.correctCount += 1
                if index == self.stackContainer.cardViews.count - 1 {
                    let alert = UIAlertController(title: "시험 종료", message: "점수: \(self.stackContainer.correctCount)/\(self.stackContainer.cardViews.count)", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.stackContainer.correctCount = 0
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        testView.wrongButtonTapHandler = {
            let index = self.stackContainer.cardViews.count - self.stackContainer.visibleCards.count
            if index < self.stackContainer.cardViews.count {
                self.stackContainer.swipeDidEnd(on: (self.stackContainer.cardViews[index]))
                let header: HTTPHeaders = [
                    "Authorization": self.token
                ]
                let parameters: Parameters = [
                    "state": "wrong"
                ]
                guard let id = self.stackContainer.cardViews[index].dataSource?.id else { return }
                AF.request("http://52.78.37.13/api/words/\(id)/test/", method: .patch, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).response { response in
                    switch response.result {
                    case .success:
                        print(id)
                        return
                    case .failure:
                        return
                    }
                }
                if index == self.stackContainer.cardViews.count - 1 {
                    let alert = UIAlertController(title: "시험 종료", message: "점수: \(self.stackContainer.correctCount)/\(self.stackContainer.cardViews.count)", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.stackContainer.correctCount = 0
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        testView.resetButtonTapHandler = {
            self.stackContainer.correctCount = 0
            self.resetTapped()
        }
    }

    //MARK: - Configurations
    func configureStackContainer() {
        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: 350).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: 450).isActive = true
    }

    func configureNavigationBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetTapped))
    }

    func configureCorrectButton() {

    }

    //MARK: - Handlers
    @objc func resetTapped() {
        stackContainer.reloadData()
    }

    @IBAction func correctButton(_ sender: Any) {
    }

    @IBAction func wrongButton(_ sender: Any) {
    }

}

extension wordsTestViewController : SwipeCardsDataSource {
    func numberOfCardsToShow() -> Int {
        return wordData.count
    }

    func card(at index: Int) -> SwipeCardView {
        let card = SwipeCardView()
        card.dataSource = wordData[index]
        return card
    }

    func emptyView() -> UIView? {
        return nil
    }

}

class TestView: UIView {
    private let xibName = "TestView"
    
    var correctButtonTapHandler: (() -> Void)?
    var wrongButtonTapHandler: (() -> Void)?
    var resetButtonTapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    @IBAction func correctButton(_ sender: Any) {
        correctButtonTapHandler?()
    }
    @IBAction func wrongButton(_ sender: Any) {
        wrongButtonTapHandler?()
    }
    @IBAction func resetButton(_ sender: Any) {
        resetButtonTapHandler?()
    }
}
