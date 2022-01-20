struct Content: Codable, Equatable {
    let contents: String?
}

struct WordsDetail: Codable {
    let id: Int?
    var contents: String?
    var spelling: String?
    var category: String?
    var meaning: String?
    var remember: Bool?
    var wrong_count: Int?
    let account: Int?
}

struct WordsUpdate: Codable {
    let msg: String?
    let word: WordsDetail?
}
