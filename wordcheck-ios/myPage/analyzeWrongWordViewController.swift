import UIKit
import Alamofire
import AVFoundation

class analyzeWrongWordViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let wordsDetailUrl = "https://wordcheck.sulrae.com/api/words/detail_list/"
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    let wrongList = Storage.retrive("wrong_list.json", from: .caches, as: [Int].self) ?? []
    var detailList: [WordsDetail] = []
    var bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setList()
    }
    
    func setList() {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        let parameters = [
            "wrong_count": "\(wrongList.last!)"
        ]
        AF.request(wordsDetailUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
            switch response.result {
            case .success:
                guard let detailList = response.value else { return }
                self.detailList = detailList.sorted(by: {$0.spelling! < $1.spelling!})
                Storage.store(self.detailList, to: .caches, as: "analyze_wrong.json")
                self.detailList = Storage.retrive("analyze_wrong.json", from: .caches, as: [WordsDetail].self) ?? []
                self.tableView.reloadData()
                
            case .failure:
                return
            }
        }
    }
}

extension analyzeWrongWordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wrongCell", for: indexPath) as? WrongCell else { return UITableViewCell() }
        cell.contentLabel.text = detailList[indexPath.row].contents
        cell.spellingLabel.text = detailList[indexPath.row].spelling
        cell.categoryLabel.text = detailList[indexPath.row].category
        cell.meaningLabel.text = detailList[indexPath.row].meaning
        cell.countLabel.text = "툴린 횟수: \(detailList[indexPath.row].wrong_count!)"
        if bookMarkList.contains(self.detailList[indexPath.row]) {
            cell.bookMarkButton.isSelected = true
        }
        cell.bookMarkButtonTapHandler = {
            cell.bookMarkButton.isSelected = !cell.bookMarkButton.isSelected
            self.detailList[indexPath.row].remember = cell.bookMarkButton.isSelected
            
            if cell.bookMarkButton.isSelected == true && !self.bookMarkList.contains(self.detailList[indexPath.row]) {
                self.bookMarkList.append(self.detailList[indexPath.row])
                cell.bookMarkButton.isSelected = false
            } else if cell.bookMarkButton.isSelected == false {
                self.bookMarkList = self.bookMarkList.filter({ $0.id != self.detailList[indexPath.row].id })
            }
            Storage.store(self.bookMarkList, to: .documents, as: "bookmark_list.json")
        }
        cell.speechButtonTapHandler = {
            let utterance = AVSpeechUtterance(string: cell.spellingLabel.text!)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synthesizer.speak(utterance)
        }
        return cell
    }
}

class WrongCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var bookMarkButton: UIButton!
    @IBOutlet weak var speechButton: UIButton!
    
    var bookMarkButtonTapHandler: (() -> Void)?
    var speechButtonTapHandler: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
    }
    
    @IBAction func bookMarkButton(_ sender: Any) {
        bookMarkButtonTapHandler?()
    }
    @IBAction func speechButton(_ sender: Any) {
        speechButtonTapHandler?()
    }
}
