import UIKit
import AVFoundation

class wordsBookMarkViewController: UIViewController {
    @IBOutlet weak var wordCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var bookMarkList: [WordsDetail] = []
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.topItem?.title = "나의 북마크"
        bookMarkList = Storage.retrive("bookmark_list.json", from: .documents, as: [WordsDetail].self) ?? []
        bookMarkList = bookMarkList.sorted(by: { $0.contents! < $1.contents! })
        wordCount.text = "단어 수: \(bookMarkList.count)"
        tableView.reloadData()
    }
}

extension wordsBookMarkViewController: UITableViewDataSource {
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
            self.wordCount.text = "단어 수: \(self.bookMarkList.count)"
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

extension wordsBookMarkViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}
