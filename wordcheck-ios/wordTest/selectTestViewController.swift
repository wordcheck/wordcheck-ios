import UIKit
import Alamofire
import DropDown

class selectTestViewController: UIViewController {

    @IBOutlet weak var selectCardButton: UIButton!
    @IBOutlet weak var selectFourButton: UIButton!
    @IBOutlet weak var selectDictationButton: UIButton!
    
    private let wordsDetailUrl = "http://52.78.37.13/api/words/detail_list/"
    private let token = Storage.retrive("user_info.json", from: .documents, as: User.self)!.account_token!
    var contents: [Content] = []
    var testList: [String] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "cardTest":
            let vc = segue.destination as? cardTestViewController
            if let content = sender as? String {
                vc?.content = content
            }
        case "selectFourTest":
            let vc = segue.destination as? selectFourTestViewController
            if let content = sender as? String {
                vc?.content = content
            }
        case "dictationTest":
            let vc = segue.destination as? dictationTestViewController
            if let content = sender as? String {
                vc?.content = content
            }
        default:
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTestList()
    }
    
    func setTestList() {
        selectCardButton.layer.borderWidth = 1
        selectCardButton.layer.borderColor = UIColor.lightGray.cgColor
        selectCardButton.layer.cornerRadius = 16
        selectFourButton.layer.borderWidth = 1
        selectFourButton.layer.borderColor = UIColor.lightGray.cgColor
        selectFourButton.layer.cornerRadius = 16
        selectDictationButton.layer.borderWidth = 1
        selectDictationButton.layer.borderColor = UIColor.lightGray.cgColor
        selectDictationButton.layer.cornerRadius = 16
        
        contents = Storage.retrive("contents_list.json", from: .caches, as: [Content].self) ?? []
        let count = contents.count
        for i in 0..<count {
            guard let list = contents[i].contents else { return }
            testList.append(list)
        }
        testList = testList.sorted(by: {$0 < $1})
    }
    
    @IBAction func selectCardButton(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.backgroundColor = UIColor.white
        dropDown.anchorView = selectCardButton
        dropDown.direction = .bottom
        dropDown.dataSource = testList
        dropDown.selectionAction = { [] (index: Int, item: String) in
            // ! 로컬로 받아놓으면 굳이 통신 안해도 될듯
            let header: HTTPHeaders = [
                "Authorization": self.token
            ]
            let parameters: Parameters = [
                "contents": item
            ]
            AF.request(self.wordsDetailUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
                switch response.result {
                case .success:
                    guard let testList = response.value else { return }
                    Storage.store(testList, to: .caches, as: "words_test.json")
                    self.performSegue(withIdentifier: "cardTest", sender: item)
                case .failure:
                    return
                }
            }
        }
        dropDown.show()
    }
    
    @IBAction func selectFourButton(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.backgroundColor = UIColor.white
        dropDown.anchorView = selectFourButton
        dropDown.direction = .bottom
        dropDown.dataSource = testList
        dropDown.selectionAction = { [] (index: Int, item: String) in
            // ! 로컬로 받아놓으면 굳이 통신 안해도 될듯
            let header: HTTPHeaders = [
                "Authorization": self.token
            ]
            let parameters: Parameters = [
                "contents": item
            ]
            AF.request(self.wordsDetailUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
                switch response.result {
                case .success:
                    guard let testList = response.value else { return }
                    if testList.count < 4 {
                        let alert = UIAlertController(title: "알림", message: "단어 수가 최소 4개 이상이어야 합니다", preferredStyle: .alert)
                        let confirm = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(confirm)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    Storage.store(testList, to: .caches, as: "words_test.json")
                    self.performSegue(withIdentifier: "selectFourTest", sender: item)
                case .failure:
                    return
                }
            }
        }
        dropDown.show()
    }
    
    @IBAction func selectDictationButton(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.backgroundColor = UIColor.white
        dropDown.anchorView = selectDictationButton
        dropDown.direction = .bottom
        dropDown.dataSource = testList
        dropDown.selectionAction = { [] (index: Int, item: String) in
            // ! 로컬로 받아놓으면 굳이 통신 안해도 될듯
            let header: HTTPHeaders = [
                "Authorization": self.token
            ]
            let parameters: Parameters = [
                "contents": item
            ]
            AF.request(self.wordsDetailUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<300).responseDecodable(of: [WordsDetail].self) { response in
                switch response.result {
                case .success:
                    guard let testList = response.value else { return }
                    Storage.store(testList, to: .caches, as: "words_test.json")
                    self.performSegue(withIdentifier: "dictationTest", sender: item)
                case .failure:
                    return
                }
            }
        }
        dropDown.show()
    }
}
