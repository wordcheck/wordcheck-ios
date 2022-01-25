import UIKit

struct WordCard {
    var id: Int
    var spelling: String
    var category: String
    var meaning: String
    var wrongCount: Int
    
    init(id: Int, spelling: String, category: String, meaning: String, wrongCount: Int) {
        self.id = id
        self.spelling = spelling
        self.category = category
        self.meaning = meaning
        self.wrongCount = wrongCount
    }
}
