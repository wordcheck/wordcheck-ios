import UIKit
import Alamofire

class cardTestViewController: UIViewController {
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var content = ""
    let testList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
    var bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
    
    var correctList: [WordsDetail] = []
    var wrongList: [WordsDetail] = []
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = content
        setCardTest()
    }

    //MARK: - Configurations
    func configureStackContainer() {
        let cardWidth = UIScreen.main.bounds.width * 3 / 4
        let cardHeight = UIScreen.main.bounds.height / 2
        
        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
    }

    //MARK: - Handlers
    func setCardTest() {
        for i in 0..<testList.count {
            guard let id = testList[i].id,
                  let spell = testList[i].spelling,
                  let cate = testList[i].category,
                  let mean = testList[i].meaning,
                  let count = testList[i].wrong_count else { return }
            wordData.append(WordCard(id: id, spelling: spell, category: cate, meaning: mean, wrongCount: count))
        }
        stackContainer.dataSource = self
        
        testView.correctButtonTapHandler = {
            let index = self.stackContainer.cardViews.count - self.stackContainer.visibleCards.count
            if index < self.stackContainer.cardViews.count {
                self.correctList.append(self.testList[index])
                self.stackContainer.swipeDidEnd(on: (self.stackContainer.cardViews[index]))
                if index == self.stackContainer.cardViews.count - 1 {
                    let alert = UIAlertController(title: "알림", message: "시험 종료", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default) { action in
                        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "testResult") as? testResultViewController else { return }
                        vc.modalTransitionStyle = .coverVertical
                        vc.correctList = self.correctList
                        vc.wrongList = self.wrongList
                        self.correctList = []
                        self.wrongList = []
                        self.present(vc, animated: true, completion: nil)
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        testView.wrongButtonTapHandler = {
            let index = self.stackContainer.cardViews.count - self.stackContainer.visibleCards.count
            if index < self.stackContainer.cardViews.count {
                self.wrongList.append(self.testList[index])
                self.stackContainer.swipeDidEnd(on: (self.stackContainer.cardViews[index]))
                if index == self.stackContainer.cardViews.count - 1 {
                    let alert = UIAlertController(title: "알림", message: "시험 종료", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default) { action in
                        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "testResult") as? testResultViewController else { return }
                        vc.modalTransitionStyle = .coverVertical
                        vc.correctList = self.correctList
                        vc.wrongList = self.wrongList
                        self.correctList = []
                        self.wrongList = []
                        self.present(vc, animated: true, completion: nil)
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        testView.resetButtonTapHandler = {
            self.correctList = []
            self.wrongList = []
            self.resetTapped()
        }
        
        testView.bookMarkButtonTapHandler = {
            let index = self.stackContainer.cardViews.count - self.stackContainer.visibleCards.count
            let target = self.testList.filter{ $0.id == self.stackContainer.cardViews[index].dataSource?.id }
            if !self.bookMarkList.contains(target.first!) {
                let alert = UIAlertController(title: "알림", message: "북마크에 추가되었습니다", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default) { action in
                    self.bookMarkList.append(target.first!)
                    Storage.store(self.bookMarkList, to: .documents, as: "bookmark_list.json")
                }
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "알림", message: "북마크에서 제거되었습니다", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default) { action in
                    self.bookMarkList = self.bookMarkList.filter{ $0 != target.first! }
                    Storage.store(self.bookMarkList, to: .documents, as: "bookmark_list.json")
                }
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func resetTapped() {
        stackContainer.reloadData()
    }
}

extension cardTestViewController : SwipeCardsDataSource {
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
