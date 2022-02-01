import UIKit
import Alamofire

class loginViewController: UIViewController {
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    private let loginURL = "https://wordcheck.sulrae.com/api/accounts/normal_login/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userInfo = Storage.retrive("user_info.json", from: .documents, as: User.self) ?? nil
        guard userInfo?.account_token != nil else { return }
        self.performSegue(withIdentifier: "startWordCheck", sender: nil)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let parameters: Parameters = [
            "nickname" : nickName.text!,
            "password" : passWord.text!
        ]
        
        AF.request(loginURL, method: .post, parameters: parameters).validate(statusCode: 200..<300).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success:
                guard let user = response.value else { return }
                if(user.account_token != nil) {
                    Storage.store(user, to: .documents, as: "user_info.json")
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
