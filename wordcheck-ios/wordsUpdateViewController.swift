import UIKit
import Alamofire

class wordsUpdateViewController: UIViewController {
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var index: Int!
    var wordDetail = Storage.retrive("words_detail.json", from: .documents, as: [WordsDetail].self) ?? []
    
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!
    @IBOutlet weak var meaningInput: UITextField!
    
    override func viewDidLoad() {
        //spellingInput.placeholder = wordDetail?.spelling
        super.viewDidLoad()
    }

    @IBAction func updateButton(_ sender: Any) {
        print("\(self.index)")
//        let header: HTTPHeaders = [
//            "Authorization": self.token
//        ]
//        let parameters: Parameters = [
//            "spelling": spellingInput.text!,
//            "category": categoryInput.text!,
//            "meaning": meaningInput.text!
//        ]
//        let id = String(describing: self.wordDetail[index].id)
//        print("--> [\(id)]")
//        AF.request("http://52.78.37.13/api/words/\(id)/", method: .patch, parameters: parameters, encoding: URLEncoding.queryString, headers: header).validate(statusCode: 200..<500).response { response in
//            switch response.result {
//            case .success:
//                let alert = UIAlertController(title: "알림", message: "단어 수정 성공", preferredStyle: UIAlertController.Style.alert)
//                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
//                alert.addAction(confirm)
//                DispatchQueue.main.async(execute: {
//                    self.present(alert, animated: true, completion: nil)
//                })
//
//            case .failure:
//                let alert = UIAlertController(title: "알림", message: "단어 수정 실패", preferredStyle: UIAlertController.Style.alert)
//                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
//                alert.addAction(confirm)
//                DispatchQueue.main.async(execute: {
//                    self.present(alert, animated: true, completion: nil)
//                })
//            }
//        }
    }
    
}
