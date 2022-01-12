import UIKit
import Alamofire

class wordsCreateViewController: UIViewController {

    @IBOutlet weak var contentsInput: UITextField!
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!  // ! category select로 처리하기
    @IBOutlet weak var meaningInput: UITextField!
    
    var token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func wordsCreateButton(_ sender: Any) {
        let header: HTTPHeaders = [
            "Authorization": token
        ]
        
        let parameters: Parameters = [
            "contents": contentsInput.text!,
            "spelling": spellingInput.text!,
            "category": categoryInput.text!,
            "meaning": meaningInput.text!
        ]
        
        AF.request("http://52.78.37.13/api/words/", method: .post, parameters: parameters, headers: header).validate(statusCode: 200..<500).response { response in
            switch response.result {
            case .success:
                let alert = UIAlertController(title: "알림", message: "단어 추가 성공", preferredStyle: UIAlertController.Style.alert)
                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                alert.addAction(confirm)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                })
                
                
            case .failure:
                return
            }
        }
        
    }
    
}
