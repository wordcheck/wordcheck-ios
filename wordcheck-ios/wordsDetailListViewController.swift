import UIKit

class wordsDetailListViewController: UIViewController {

    var detailList: [WordsDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.detailList)
    }

}

extension wordsDetailListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath) as? DetailCell else {
            return UITableViewCell()
        }
        cell.spellingLabel.text = self.detailList[indexPath.row].spelling
        cell.categoryLabel.text = self.detailList[indexPath.row].category
        cell.meaningLabel.text = self.detailList[indexPath.row].meaning
        return cell
    }
    
    
}

extension wordsDetailListViewController: UITableViewDelegate {
    
}

class DetailCell: UITableViewCell {
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
}
