import UIKit
import Alamofire

class loginViewController: UIViewController {
    
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func nickName(_ sender: Any) {

    }
    @IBAction func passWord(_ sender: Any) {
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let loginURL = "http://52.78.37.13/api/accounts/normal_login/"
        let parameters: Parameters = [
            "nickname" : nickName.text!,
            "password" : passWord.text!
        ]
        
        print("--> \(nickName.text!), \(passWord.text!)")
        
        AF.request(loginURL, method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let obj):
                do {
                    let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let getData = try JSONDecoder().decode(accountToken.self, from: dataJSON)
                    guard let msg = getData.msg else { return }
                    if msg == "success" {
                        //print("좋아용")
                    }
                } catch {
                    print(error.localizedDescription)
                }
            default:
                return
            }

        }
    }
}

struct accountToken: Codable {
    let account_token: String?
    let msg: String?
    let nickname: String?
}

class loginAPI {
    
    static func nickNameCheck(_ nickname: String) -> Void {

    }
    
    static func normalLogin() -> Void {

    }
    
    static func normalSignup() -> Void {
        
    }
    
}
