import UIKit

class DetailCell: BaseTableViewCell {
    @IBOutlet weak var spellingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var bookMarkButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    var updateButtonTapHandler: (() -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
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

