import UIKit
import AVFoundation

class wordsBookMarkViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var bookMarkList: [WordsDetail] = []
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
        self.tableView.reloadData()
    }
}

extension wordsBookMarkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookMarkList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "bookMarkCell", for: indexPath) as? BookMarkCell else {
            return UITableViewCell()
        }
        cell.contentLabel.text = bookMarkList[indexPath.row].contents
        cell.spellingLabel.text = bookMarkList[indexPath.row].spelling
        cell.categoryLabel.text = bookMarkList[indexPath.row].category
        cell.meaningLabel.text = bookMarkList[indexPath.row].meaning
        cell.countLabel.text = "툴린 횟수: \(bookMarkList[indexPath.row].wrong_count ?? 0)"
        
        cell.bookMarkButtonTapHandler = {
            self.bookMarkList = self.bookMarkList.filter { $0.id != self.bookMarkList[indexPath.row].id }
            Storage.store(self.bookMarkList, to: .documents, as: "bookmark_list.json")
            self.tableView.reloadData()
        }
        
        cell.speechButtonTapHandler = {
            let utterance = AVSpeechUtterance(string: cell.spellingLabel.text!)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synthesizer.speak(utterance)
        }
        
        return cell
    }
    
}

class BookMarkCell: UITableViewCell {
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
