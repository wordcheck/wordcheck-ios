import UIKit

class loginViewController: UIViewController {

    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func nickName(_ sender: Any) {
        guard let nickname = nickName?.text else { return }
        loginAPI.nickNameCheck(nickname)
    }
    @IBAction func passWord(_ sender: Any) {
    }
    
    @IBAction func loginButton(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(identifier: "wordsList") else { return }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

class loginAPI {
    
    static func nickNameCheck(_ nickname: String) -> Void {
        let session = URLSession(configuration: .default)
        let requestURL = URLComponents(string: "52.78.37.13/accounts/nickname_check")!.url!
        
    }
    
    static func normalLogin() -> Void {
        let session = URLSession(configuration: .default)
        let requestURL = URLComponents(string: "52.78.37.13/accounts/normal_login")!.url!
       
        
    }
    
    static func normalSignup() -> Void {
        
    }
    
}
