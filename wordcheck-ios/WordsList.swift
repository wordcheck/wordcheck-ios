import UIKit

struct WordsDetail: Codable {
    let id: Int?
    let contents: String?
    let spelling: String?
    let category: String?
    let meaning: String?
    let remember: Bool?
    let wrong_count: Int?
    let account: Int?
}
