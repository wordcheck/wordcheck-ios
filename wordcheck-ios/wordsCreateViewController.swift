import UIKit
import Alamofire

class wordsCreateViewController: UIViewController {

    @IBOutlet weak var contentsInput: UITextField!
    @IBOutlet weak var spellingInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!  // ! category select로 처리하기
    @IBOutlet weak var meaningInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func wordsCreateButton(_ sender: Any) {
        // words post api
        let header: HTTPHeaders = [
            // 토큰은 로컬로 처리하기
            "Authorization": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWNrbmFtZSI6ImppaG8xIn0.T3oI95w17JUZ5a2DTUsMzVjLFFQwngsf7xrFWXdDfn0"
        ]
        
        let parameters: Parameters = [
            "contents": contentsInput.text!,
            "spelling": spellingInput.text!,
            "category": categoryInput.text!,
            "meaning": meaningInput.text!
        ]
        AF.request("http://52.78.37.13/api/words/", method: .post, parameters: parameters, headers: header).responseJSON { response in
            switch response.result {
            case .success:
                // 성공했다 알림
                let alert = UIAlertController(title: "알림", message: "단어 추가 성공", preferredStyle: UIAlertController.Style.alert)
                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)

            default:
                return
            }
        }
        
    }
    
}
