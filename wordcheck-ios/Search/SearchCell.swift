import UIKit

class ResultCell: BaseTableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var bookMarkButton: UIButton!
    @IBOutlet weak var speechButton: UIButton!
    
    @IBAction func bookMarkButton(_ sender: Any) {
        bookMarkButtonTapHandler?()
    }
    @IBAction func speechButton(_ sender: Any) {
        speechButtonTapHandler?()
    }
}
