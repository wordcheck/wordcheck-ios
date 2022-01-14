import UIKit
import Alamofire

class loginViewController: UIViewController {
    
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Storage.clear(.documents)
    }

    @IBAction func nickName(_ sender: Any) {
        // 실시간 닉네임 중복 체크
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let parameters: Parameters = [
            "nickname" : nickName.text!,
            "password" : passWord.text!
        ]
        AF.request("http://52.78.37.13/api/accounts/normal_login/", method: .post, parameters: parameters).validate(statusCode: 200..<500).responseDecodable(of: loginToken.self) { response in
            switch response.result {
            case .success:
                guard let token = response.value?.account_token else { return }
                if(token != "") {
                    Storage.store(token, to: .documents, as: "account_token.json")
                    let header: HTTPHeaders = [
                        "Authorization": token
                    ]
                    AF.request("http://52.78.37.13/api/words/", method: .get, headers: header).validate(statusCode: 200..<500).responseDecodable(of: [Content].self) { response in
                        switch response.result {
                        case .success:
                            guard let list = response.value else { return }
                            Storage.store(list, to: .caches, as: "contents_list.json")
                                    
                        case .failure:
                            return
                        }
                        self.performSegue(withIdentifier: "getWords", sender: nil)
                        self.dismiss(animated: false, completion: nil)
                    }
                }

            case .failure:
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
    
//    enum CodingKeys: CodingKey {
//        case account_token, msg, nickname
//    }
//    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        account_token = (try? values.decode(String.self, forKey: .account_token)) ?? nil
//        msg = (try? values.decode(String.self, forKey: .msg)) ?? nil
//        nickname = (try? values.decode(String.self, forKey: .nickname)) ?? nil
//    }
}
