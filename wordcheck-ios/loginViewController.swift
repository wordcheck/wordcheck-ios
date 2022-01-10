import UIKit
import Alamofire

class loginViewController: UIViewController {
    
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!

    var contentsList: [Words] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getWords" {
            let vc = segue.destination as? wordsListViewController
            if let contents = sender as? [Words] {
                vc?.contentsList = contents
            }
        }
    }
    
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
        
        AF.request(loginURL, method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let obj):
                do {
                    let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let getData = try JSONDecoder().decode(loginToken.self, from: dataJSON)
                    guard let token = getData.account_token else { return }
                    if token != "" {
                        // account_token 받아옴
                        let header: HTTPHeaders = [
                            "Authorization": token // 토큰은 로컬에 저장하기로
                        ]
                        AF.request("http://52.78.37.13/api/words/", method: .get, headers: header).responseJSON { response in
                            switch response.result {
                            case .success(let obj):
                                // 단어 처리
                                do {
                                    let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                                    let getData = try JSONDecoder().decode([Words].self, from: dataJSON)
                                    self.contentsList = getData
                                } catch {
                                    print(error.localizedDescription)
                                }

                            default:
                                return
                            }
                            self.performSegue(withIdentifier: "getWords", sender: self.contentsList)
                        }

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
