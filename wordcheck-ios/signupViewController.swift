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
                        } catch {
                            print(error.localizedDescription)
                        }
                    default:
                        return
                    }
                }
                
            default:
                return
            }

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

struct nicknameCheck: Codable {
    let msg: String?
}

struct accountToken: Codable {
    let msg: String?
    let account_token: String?
}
