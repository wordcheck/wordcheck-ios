import UIKit
import Alamofire

class loginViewController: UIViewController {
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? nil
        if token != nil {
            self.performSegue(withIdentifier: "startWordCheck", sender: nil)
        }
    }
    @IBAction func loginButton(_ sender: Any) {
        let parameters: Parameters = [
            "nickname" : nickName.text!,
            "password" : passWord.text!
        ]
        
        AF.request("http://52.78.37.13/api/accounts/normal_login/", method: .post, parameters: parameters).validate(statusCode: 200..<300).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success:
                guard let body = response.value else { return }
                if(body.account_token != nil) {
                    Storage.store(body.account_token, to: .documents, as: "account_token.json")
                    Storage.store(body, to: .documents, as: "user_info.json")
                    self.performSegue(withIdentifier: "startWordCheck", sender: nil)
                }

            default:
                let alert = UIAlertController(title: "알림", message: "아이디 또는 비밀번호 오류", preferredStyle: UIAlertController.Style.alert)
                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signupButton(_ sender: Any) {
        performSegue(withIdentifier: "signUp", sender: nil)
    }
}