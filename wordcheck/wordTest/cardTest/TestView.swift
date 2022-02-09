import UIKit

class TestView: UIView {
    @IBOutlet weak var bookMarkButton: UIButton!
    
    private let xibName = "TestView"
    
    var correctButtonTapHandler: (() -> Void)?
    var bookMarkButtonTapHandler: (() -> Void)?
    var wrongButtonTapHandler: (() -> Void)?
    var resetButtonTapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    @IBAction func correctButton(_ sender: Any) {
        correctButtonTapHandler?()
    }
    @IBAction func bookMarkButton(_ sender: Any) {
        bookMarkButtonTapHandler?()
    }
    @IBAction func wrongButton(_ sender: Any) {
        wrongButtonTapHandler?()
    }
    @IBAction func resetButton(_ sender: Any) {
        resetButtonTapHandler?()
    }
}
