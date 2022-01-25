import UIKit
import Alamofire
import AVFoundation

class wordsDetailListViewController: UIViewController {
    @IBOutlet weak var wordCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: LoadViewDelegate?
    
    let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var contentList = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
    var detailList: [WordsDetail] = []
    var bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailList = Storage.retrive("words_detail.json", from: .caches, as: [WordsDetail].self) ?? []
        wordCount.text = "단어 수: \(detailList.count)"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Storage.store(self.bookMarkList, to: .documents, as: "bookmark_list.json")
        self.tableView.reloadData()
    }
}

extension wordsDetailListViewController: LoadViewDelegate {
    func loadCreateTableView() {}
    func loadUpdateTableView() {
        self.detailList = Storage.retrive("words_detail.json", from: .caches, as: [WordsDetail].self) ?? []
        self.tableView.reloadData()
    }
    func loadDeleteTableView() {}
}

extension wordsDetailListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath) as? DetailCell else { return UITableViewCell() }
        cell.contentLabel.text = self.detailList[indexPath.row].contents
        cell.spellingLabel.text = self.detailList[indexPath.row].spelling
        cell.categoryLabel.text = self.detailList[indexPath.row].category
        cell.meaningLabel.text = self.detailList[indexPath.row].meaning
        cell.countLabel.text = "툴린 횟수: \(self.detailList[indexPath.row].wrong_count ?? 0)"
        if bookMarkList.contains(where: { $0.id == self.detailList[indexPath.row].id }) {
            cell.bookMarkButton.isSelected = true
        }
        cell.updateButtonTapHandler = {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "wordsUpdateViewController") as? wordsUpdateViewController else { return }
            vc.index = indexPath.row
            vc.modalTransitionStyle = .coverVertical
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        cell.deleteButtonTapHandler = {
            let header: HTTPHeaders = [
                "Authorization": self.token
            ]
            let id = self.detailList[indexPath.row].id!
            let content = self.detailList[indexPath.row].contents!

            AF.request("http://52.78.37.13/api/words/\(id)/", method: .delete, headers: header).validate(statusCode: 200..<300).response { response in
                switch response.result {
                case .success:
                    let alert = UIAlertController(title: "알림", message: "단어 삭제 성공", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.detailList = self.detailList.filter { $0.id != id }
                //        if let index = detailList.firstIndex(of: WordsDetail) {
                //            detailList.remove(at: index)
                //        }
                        Storage.store(self.detailList, to: .caches, as: "words_detail.json")
                        self.tableView.reloadData()
                        
                        if self.detailList.count == 0 {
                            self.contentList = self.contentList.filter { $0.contents != content }
                            Storage.store(self.contentList, to: .caches, as: "contents_list.json")
                            self.delegate?.loadDeleteTableView()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)

                default:
                    return
                }
            }
        }
        cell.bookMarkButtonTapHandler = {
            cell.bookMarkButton.isSelected = !cell.bookMarkButton.isSelected
            self.detailList[indexPath.row].remember = cell.bookMarkButton.isSelected
            
            if cell.bookMarkButton.isSelected == true && !self.bookMarkList.contains(where: { $0 == self.detailList[indexPath.row] }) {
                self.bookMarkList.append(self.detailList[indexPath.row])
            } else if cell.bookMarkButton.isSelected == false {
                self.bookMarkList = self.bookMarkList.filter({ $0.id != self.detailList[indexPath.row].id })
            }
        }
        cell.speechButtonTapHandler = {
            let utterance = AVSpeechUtterance(string: cell.spellingLabel.text!)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synthesizer.speak(utterance)
        }
        return cell
    }
}

class DetailCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var bookMarkButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    var updateButtonTapHandler: (() -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    var bookMarkButtonTapHandler: (() -> Void)?
    var speechButtonTapHandler: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
    }
    
    @IBAction func updateButton(_ sender: Any) {
        updateButtonTapHandler?()
    }
    @IBAction func deleteButton(_ sender: Any) {
        deleteButtonTapHandler?()
    }
    @IBAction func bookMarkButton(_ sender: Any) {
        bookMarkButtonTapHandler?()
    }
    @IBAction func speechButton(_ sender: Any) {
        speechButtonTapHandler?()
    }
}
