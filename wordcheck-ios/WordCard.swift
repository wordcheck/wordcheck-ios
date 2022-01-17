import UIKit

struct WordCard {
    var id: Int
    var spelling: String
    var category: String
    var meaning: String
    
    init(id: Int, spelling: String, category: String, meaning: String) {
        self.id = id
        self.spelling = spelling
        self.category = category
        self.meaning = meaning
    }
}
