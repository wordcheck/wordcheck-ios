import UIKit
import Alamofire

class LoginViewController: UIViewController {
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private let loginURL = "https://wordcheck.sulrae.com/api/accounts/normal_login/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nickName.becomeFirstResponder()
        let userInfo = Storage.retrive("user_info.json", from: .documents, as: User.self) ?? nil
        guard userInfo?.account_token != nil else { return }
        Storage.store(userInfo, to: .documents, as: "user_info.json")
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "startWordCheck") else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func nicknameChange(_ sender: Any) {
        if nickName.text != "" && passWord.text != "" {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    @IBAction func passwordChange(_ sender: Any) {
        if nickName.text != "" && passWord.text != "" {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    @IBAction func loginButton(_ sender: Any) {
        loginButton.isEnabled = false
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
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "startWordCheck") else { return }
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true, completion: nil)
                }
            default:
                let alert = UIAlertController(title: "알림", message: "아이디 또는 비밀번호 오류", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
                self.loginButton.isEnabled = true
            }
        }
    }
    
    @IBAction func signupButton(_ sender: Any) {
        performSegue(withIdentifier: "signUp", sender: nil)
    }
    
    @IBAction func touchView(_ sender: Any) {
        nickName.resignFirstResponder()
        passWord.resignFirstResponder()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == nickName {
            passWord.becomeFirstResponder()
        }
        return true
    }
}
