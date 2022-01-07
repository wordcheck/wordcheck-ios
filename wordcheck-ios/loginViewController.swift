import UIKit
import Alamofire

class loginViewController: UIViewController {
    
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
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
        
        AF.request(loginURL, method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let obj):
                do {
                    let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let getData = try JSONDecoder().decode(loginToken.self, from: dataJSON)
                    guard let msg = getData.msg else { return }
                    if msg == "success" {
                        let wordsListViewController = self.storyboard?.instantiateViewController(withIdentifier: "wordsListViewController") as! wordsListViewController
                        
                        self.navigationController?.pushViewController(wordsListViewController, animated: true)
                        
                        self.dismiss(animated: false, completion: nil)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            default:
                return
            }

        }
    }
    
    @IBAction func signupButton(_ sender: Any) {
        let signupViewController = self.storyboard?.instantiateViewController(withIdentifier: "signupViewController") as! signupViewController
        
        self.navigationController?.pushViewController(signupViewController, animated: true)
        
        self.dismiss(animated: false, completion: nil)
    }
    
}

struct loginToken: Codable {
    let account_token: String?
    let msg: String?
    let nickname: String?
}
