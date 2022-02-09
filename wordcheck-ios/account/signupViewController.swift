import UIKit
import Alamofire

class signupViewController: UIViewController {
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var nickNameLength: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    
    private let nickNameCheckURL = "https://wordcheck.sulrae.com/api/accounts/nickname_check/"
    private let signUpURL = "https://wordcheck.sulrae.com/api/accounts/normal_signup/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nickName.becomeFirstResponder()
        signupButton.isEnabled = false
    }
    
    @IBAction func nickName(_ sender: Any) {
        let parameters: Parameters = [
            "nickname": nickName.text!
        ]
        
        if nickName.text == "" {
            let alert = UIAlertController(title: "알림", message: "닉네임을 입력해주세요", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        } else {
            AF.request(nickNameCheckURL, method: .post, parameters: parameters).validate(statusCode: 200..<300).response { response in
                switch response.result {
                case .success:
                    return
                default:
                    let alert = UIAlertController(title: "알림", message: "중복된 닉네임 입니다", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func nickNameLength(_ sender: Any) {
        nickNameLength.text = "\(nickName.text!.count)/20"
        limitLength(textField: nickName, maxLength: 20)
        if nickName.text != "" && passWord.text != "" { signupButton.isEnabled = true
        } else { signupButton.isEnabled = false }
    }
    @IBAction func passWordChange(_ sender: Any) {
        if nickName.text != "" && passWord.text != "" { signupButton.isEnabled = true
        } else { signupButton.isEnabled = false }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        signupButton.isEnabled = false
        let parameters: Parameters = [
            "nickname": self.nickName.text!,
            "password": self.passWord.text!,
            "secret_code": "980117"
        ]
        
        AF.request(signUpURL, method: .post, parameters: parameters).validate(statusCode: 200..<300).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success:
                let alert = UIAlertController(title: "알림", message: "가입된 아이디로 로그인 해주세요", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default) { action in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
                self.signupButton.isEnabled = true
            case .failure:
                let alert = UIAlertController(title: "알림", message: "가입 오류", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
                self.signupButton.isEnabled = true
            }
        }
    }
    
    @IBAction func touchView(_ sender: Any) {
        nickName.resignFirstResponder()
        passWord.resignFirstResponder()
    }
}

extension signupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == nickName {
            passWord.becomeFirstResponder()
        }
        return true
    }
    
    func limitLength(textField: UITextField, maxLength: Int) {
        if textField.text!.count > maxLength {
            textField.deleteBackward()
        }
    }
}
