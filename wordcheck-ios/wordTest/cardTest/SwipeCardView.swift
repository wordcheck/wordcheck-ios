import UIKit
import Alamofire

class SwipeCardView: UIView {
//    let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    
    //MARK: - Properties
    var swipeView: UIView!
    var shadowView: UIView!
  
    var spell = UILabel()
    
    var delegate: SwipeCardsDelegate?

    var divisor: CGFloat = 0
    let baseView = UIView()

    var dataSource: WordCard? {
        didSet {
            spell.text = dataSource?.spelling
        }
    }
    
    //MARK: - Init
     override init(frame: CGRect) {
        super.init(frame: .zero)
        configureShadowView()
        configureSwipeView()
        configureSpellLabelView()
//        addPanGestureOnCards()
        configureTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuration
    func configureShadowView() {
        shadowView = UIView()
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.shadowOpacity = 0.8
        shadowView.layer.shadowRadius = 4.0
        addSubview(shadowView)
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        shadowView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        shadowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    func configureSwipeView() {
        swipeView = UIView()
        swipeView.layer.cornerRadius = 15
        swipeView.clipsToBounds = true
        shadowView.addSubview(swipeView)
        
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        swipeView.leftAnchor.constraint(equalTo: shadowView.leftAnchor).isActive = true
        swipeView.rightAnchor.constraint(equalTo: shadowView.rightAnchor).isActive = true
        swipeView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
        swipeView.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
    }
    
    func configureSpellLabelView() {
        swipeView.addSubview(spell)
        spell.backgroundColor = .white
        spell.numberOfLines = 2
        spell.adjustsFontSizeToFitWidth = true
        spell.textColor = .black
        spell.textAlignment = .center
        spell.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        spell.translatesAutoresizingMaskIntoConstraints = false
        spell.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
        spell.leftAnchor.constraint(equalTo: swipeView.leftAnchor).isActive = true
        spell.rightAnchor.constraint(equalTo: swipeView.rightAnchor).isActive = true
        spell.bottomAnchor.constraint(equalTo: swipeView.bottomAnchor).isActive = true
    }
    
    func configureTapGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
    }

//    // 추후 스와이프 추가 예정
//    func addPanGestureOnCards() {
//        self.isUserInteractionEnabled = true
//        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
//    }
//
//    //MARK: - Handlers
//    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
//        let card = sender.view as! SwipeCardView
//        let id = card.dataSource?.id
//        let point = sender.translation(in: self)
//        let centerOfParentContainer = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
//        card.center = CGPoint(x: centerOfParentContainer.x + point.x, y: centerOfParentContainer.y + point.y)
//
//        divisor = ((UIScreen.main.bounds.width / 2) / 0.61)
//
//        switch sender.state {
//        case .ended:
//            // Right (state: correct)
//            if card.center.x > UIScreen.main.bounds.width - 5 {
//                delegate?.swipeDidEnd(on: card)
//                UIView.animate(withDuration: 0.2) {
//                    card.center = CGPoint(x: centerOfParentContainer.x + point.x + 200, y: centerOfParentContainer.y + point.y + 75)
//                    card.alpha = 0
//                    self.layoutIfNeeded()
//                }
////                guard let id = id else { return }
//            // Left (state: wrong)
//            } else if card.center.x < 5 {
//                delegate?.swipeDidEnd(on: card)
//                UIView.animate(withDuration: 0.2) {
//                    card.center = CGPoint(x: centerOfParentContainer.x + point.x - 200, y: centerOfParentContainer.y + point.y + 75)
//                    card.alpha = 0
//                    self.layoutIfNeeded()
//                }
//                let header: HTTPHeaders = [
//                    "Authorization": self.token
//                ]
//                let parameters: Parameters = [
//                    "state": "wrong"
//                ]
//                guard let id = id else { return }
//                AF.request("http://52.78.37.13/api/words/\(id)/test/", method: .patch, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).response { response in
//                    switch response.result {
//                    case .success:
//                        print("wrong")
//                    default:
//                        return
//                    }
//                }
//            }
//            UIView.animate(withDuration: 0.2) {
//                card.transform = .identity
//                card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
//                self.layoutIfNeeded()
//            }
//        case .changed:
//            let rotation = tan(point.x / (self.frame.width * 2.0))
//            card.transform = CGAffineTransform(rotationAngle: rotation)
//            if card.center.x > UIScreen.main.bounds.width - 40 {
//                card.shadowView.layer.shadowColor = UIColor.green.cgColor
//            } else if card.center.x < 40 {
//                card.shadowView.layer.shadowColor = UIColor.red.cgColor
//            } else {
//                card.shadowView.layer.shadowColor = UIColor.black.cgColor
//            }
//
//        default:
//            break
//        }
//    }
    
    @objc func handleTapGesture(sender: UITapGestureRecognizer){
        if spell.text == dataSource?.spelling {
            spell.text = dataSource?.meaning
        } else {
            spell.text = dataSource?.spelling
        }
    }
    
}
