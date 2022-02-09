import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var bookMarkButtonTapHandler: (() -> Void)?
    var speechButtonTapHandler: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
    }
}
