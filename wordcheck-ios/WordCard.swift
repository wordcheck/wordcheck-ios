import UIKit

struct WordCard {
    var spelling: String
    var category: String
    var meaning: String
    
    init(spelling: String, category: String, meaning: String) {
        self.spelling = spelling
        self.category = category
        self.meaning = meaning
    }
}
