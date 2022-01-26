import UIKit
import Alamofire
import SwiftUI

class cardTestViewController: UIViewController {
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var content = ""
    let testList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
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
        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: 350).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: 450).isActive = true
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
                self.stackContainer.correctCount += 1
                guard let wrongCount = self.stackContainer.cardViews[index].dataSource?.wrongCount else { return }
                if wrongCount > 0 {
                    let header: HTTPHeaders = [
                        "Authorization": self.token
                    ]
                    let parameters: Parameters = [
                        "state": "correct"
                    ]
                    guard let id = self.stackContainer.cardViews[index].dataSource?.id else { return }
                    AF.request("http://52.78.37.13/api/words/\(id)/test/", method: .patch, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).response { response in
                        switch response.result {
                        case .success:
                            return
                        case .failure:
                            return
                        }
                    }
                }
                if index == self.stackContainer.cardViews.count - 1 {
                    let alert = UIAlertController(title: "시험 종료", message: "고생하셨습니다", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.stackContainer.correctCount = 0
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
                        return
                    case .failure:
                        return
                    }
                }
                if index == self.stackContainer.cardViews.count - 1 {
                    let alert = UIAlertController(title: "시험 종료", message: "고생하셨습니다", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.stackContainer.correctCount = 0
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
            self.stackContainer.correctCount = 0
            self.correctList = []
            self.wrongList = []
            self.resetTapped()
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