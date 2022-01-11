import UIKit
import Alamofire

class signupViewController: UIViewController {

    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var secretCode: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nickName(_ sender: Any) {
        
    }
    
    @IBAction func passWord(_ sender: Any) {
        
    }
    
    @IBAction func secretCode(_ sender: Any) {
        
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let nicknamecheckURL = "http://52.78.37.13/api/accounts/nickname_check/"
        var parameters: Parameters = [
            "nickname" : nickName.text!
        ]
        AF.request(nicknamecheckURL, method: .post, parameters: parameters).responseJSON {
            response in
            switch response.result {
            case .success:
                let signupURL = "http://52.78.37.13/api/accounts/normal_signup/"
                parameters = [
                    "nickname" : self.nickName.text!,
                    "password" : self.passWord.text!,
                    "secret_code": self.secretCode.text!
                ]
                
                AF.request(signupURL, method: .post, parameters: parameters).responseJSON { response in
                    switch response.result {
                    case .success(let obj):
                        do {
                            let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                            let getData = try JSONDecoder().decode(accountToken.self, from: dataJSON)
                            guard let token = getData.account_token else { return }
                            print("--> \(token)")
                            // 로그인 해달라고 알림
                            let alert = UIAlertController(title: "알림", message: "생성한 아이디로 로그인 해주세요", preferredStyle: UIAlertController.Style.alert)
                            self.present(alert, animated: true, completion: nil)
                            self.dismiss(animated: false, completion: nil)
                        } catch {
                            print(error.localizedDescription)
                        }
                    default:
                        let alert = UIAlertController(title: "알림", message: "닉네임 중복", preferredStyle: UIAlertController.Style.alert)
                        let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                        alert.addAction(confirm)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                
            default:
                return
            }

        }
    }

}

struct nicknameCheck: Codable {
    let msg: String?
}

struct accountToken: Codable {
    let msg: String?
    let account_token: String?
}
