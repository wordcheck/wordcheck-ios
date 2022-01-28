struct PapagoResult: Codable {
    let message: Message?
    
    struct Message: Codable {
        let result: Result
        
        struct Result: Codable {
            let translatedText: String
        }
    }
}
