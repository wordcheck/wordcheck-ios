import UIKit
import Alamofire
import SwiftUI

class wordsTestViewController: UIViewController {
    var content = ""
    let testList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
    var wordData: [WordCard] = []
    var stackContainer: StackContainerView!
    
    //MARK: - Init
    override func loadView() {
        let testView = TestView()
        view = testView
        view.backgroundColor = .systemBackground
        
        stackContainer = StackContainerView()
        view.addSubview(stackContainer)
        configureStackContainer()
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        configureNavigationBarButtonItem()
        
        testView.correctButtonTapHandler = {
            print("count: \(self.stackContainer.cardViews.count), numbertoshow: \(self.stackContainer.numberOfCardsToShow), remain: \(self.stackContainer.remainingcards)")
            //self.stackContainer.swipeDidEnd(on: (self.stackContainer.cardViews[0]))
            //print(self.stackContainer.cardViews[0])
        }
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
        wrongButtonTapHandler?()
    }
}
