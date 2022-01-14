import UIKit
import Alamofire
import SwiftUI

class wordsTestViewController: UIViewController {
    @IBOutlet weak var contentLabel: UILabel!
    
    var content = ""
    let testList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
    var wordData: [WordCard] = [
    ]
    var stackContainer: StackContainerView!
    
    //MARK: - Init
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        stackContainer = StackContainerView()
        view.addSubview(stackContainer)
        configureStackContainer()
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        configureNavigationBarButtonItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 좀 더 좋은 방법 찾아보기
        for i in 0..<testList.count {
            guard let spell = testList[i].spelling, let cate = testList[i].category, let mean = testList[i].meaning else { return }
            wordData.append(WordCard(spelling: spell, category: cate, meaning: mean))
        }
        stackContainer.dataSource = self
    }

//MARK: - Configurations
    func configureStackContainer() {
        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: 300).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    func configureNavigationBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetTapped))
    }
    
    //MARK: - Handlers
    @objc func resetTapped() {
        stackContainer.reloadData()
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
