import UIKit

class testResultViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var allWords: UIButton!
    @IBOutlet weak var correctWords: UIButton!
    @IBOutlet weak var wrongWords: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var allList = Storage.retrive("words_test.json", from: .caches, as: [WordsDetail].self) ?? []
    var correctList: [WordsDetail] = []
    var wrongList: [WordsDetail] = []
    var visibleList: [WordsDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let score = Int(Float(correctList.count) / Float(allList.count) * 100)
        scoreLabel.text = "\(score)점"
        allWords.isSelected = true
        allWords.setTitle("모든 단어(\(allList.count))", for: .normal)
        correctWords.setTitle("정답(\(correctList.count))", for: .normal)
        wrongWords.setTitle("오답(\(wrongList.count))", for: .normal)
        visibleList = allList
    }

    override func viewDidDisappear(_ animated: Bool) {
    }
    
    @IBAction func allWords(_ sender: Any) {
        allWords.isSelected = true
        correctWords.isSelected = false
        wrongWords.isSelected = false
        visibleList = allList
        self.tableView.reloadData()
    }
    @IBAction func correctWords(_ sender: Any) {
        allWords.isSelected = false
        correctWords.isSelected = true
        wrongWords.isSelected = false
        visibleList = correctList
        self.tableView.reloadData()
    }
    @IBAction func wrongWords(_ sender: Any) {
        allWords.isSelected = false
        correctWords.isSelected = false
        wrongWords.isSelected = true
        visibleList = wrongList
        self.tableView.reloadData()
    }
}

extension testResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TestResultCell", for: indexPath) as? TestResultCell else { return UITableViewCell() }
        if wrongList.contains(visibleList[indexPath.row]) {
            cell.spellingLabel.textColor = UIColor.red
        } else {
            cell.spellingLabel.textColor = UIColor.label
        }
        cell.spellingLabel.text = visibleList[indexPath.row].spelling
        cell.meaningLabel.text = visibleList[indexPath.row].meaning
        return cell
    }
}

class TestResultCell: UITableViewCell {
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
}
