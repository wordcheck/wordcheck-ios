import UIKit

class ContentCell: BaseTableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 16
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: -10, right: 20))
    }
}
