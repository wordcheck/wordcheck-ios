import UIKit
import Alamofire
import Shuffle_iOS
import SwiftUI

class wordsTestViewController: UIViewController {
    let cardStack = SwipeCardStack()
    let cardImages = [
        UIImage(named: "cardImage1"),
        UIImage(named: "cardImage2"),
        UIImage(named: "cardImage3")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cardStack)
        cardStack.frame = view.safeAreaLayoutGuide.layoutFrame
    }

    func card(fromImage image: UIImage) -> SwipeCard {
      let card = SwipeCard()
      card.swipeDirections = [.left, .right]
      card.content = UIImageView(image: image)
      
      let leftOverlay = UIView()
      leftOverlay.backgroundColor = .green
      
      let rightOverlay = UIView()
      rightOverlay.backgroundColor = .red
      
      card.setOverlays([.left: leftOverlay, .right: rightOverlay])
      
      return card
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
      return card(fromImage: cardImages[index]!)
    }

    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
      return cardImages.count
    }
    
    //cardStack.dataSource = self
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        
    }
}
