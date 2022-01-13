import UIKit
import Alamofire

class signupViewController: UIViewController {

    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nickName(_ sender: Any) {
        
    }
    
    @IBAction func passWord(_ sender: Any) {
        
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let parameters: Parameters = [
            "nickname": nickName.text!
        ]
        
        AF.request("http://52.78.37.13/api/accounts/nickname_check/", method: .post, parameters: parameters).validate(statusCode: 200..<500).response { response in
            switch response.result {
            case .success:
                let parameters: Parameters = [
                    "nickname": self.nickName.text!,
                    "password": self.passWord.text!,
                    "secret_code": "980117"
                ]
                
                AF.request("http://52.78.37.13/api/accounts/normal_signup/", method: .post, parameters: parameters).validate(statusCode: 200..<500).responseDecodable(of: loginToken.self) { response in
                    switch response.result {
                    case .success:
                        // ! 가입하면 로그인되게 처리하기
//                        guard let token = response.value?.account_token else { return }
                        
                        let alert = UIAlertController(title: "알림", message: "로그인 해주세요", preferredStyle: UIAlertController.Style.alert)
                        let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                        alert.addAction(confirm)
                        self.present(alert, animated: true, completion: nil)
                        
                    case .failure:
                        let alert = UIAlertController(title: "알림", message: "가입 오류", preferredStyle: UIAlertController.Style.alert)
                        let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                        alert.addAction(confirm)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            default:
                let alert = UIAlertController(title: "알림", message: "중복된 닉네임 입니다", preferredStyle: UIAlertController.Style.alert)
                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            }
        }

    }

}
