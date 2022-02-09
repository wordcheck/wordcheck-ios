import UIKit
import Alamofire

class signupViewController: UIViewController {
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    private let nickNameCheckURL = "https://wordcheck.sulrae.com/api/accounts/nickname_check/"
    private let signUpURL = "https://wordcheck.sulrae.com/api/accounts/normal_signup/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nickName(_ sender: Any) {
        let parameters: Parameters = [
            "nickname": nickName.text!
        ]
        
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
    
    @IBAction func signUpButton(_ sender: Any) {
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
            case .failure:
                let alert = UIAlertController(title: "알림", message: "가입 오류", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func touchView(_ sender: Any) {
        nickName.resignFirstResponder()
        passWord.resignFirstResponder()
    }
}
