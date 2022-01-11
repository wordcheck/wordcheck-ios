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
        let parameters: Parameters = [
            "nickname" : nickName.text!,
            "password" : passWord.text!
        ]
        AF.request("http://52.78.37.13/api/accounts/normal_login/", method: .post, parameters: parameters).validate(statusCode: 200..<500).responseDecodable(of: loginToken.self) { response in
            switch response.result {
            case .success:
                guard let token = response.value?.account_token else { return }
                if(token != "") {
                    // account_token 받아옴
                    // ! 토큰은 로컬에 저장하기로
                    let header: HTTPHeaders = [
                        "Authorization": token
                    ]
                    AF.request("http://52.78.37.13/api/words/", method: .get, headers: header).validate(statusCode: 200..<500).responseDecodable(of: [Words].self) { response in
                        switch response.result {
                        case .success:
                            guard let list = response.value else { return }
                            self.contentsList = list
                                    
                        case .failure:
                            return
                        }
                        self.performSegue(withIdentifier: "getWords", sender: self.contentsList)
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
    
    enum CodingKeys: CodingKey {
        case account_token, msg, nickname
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        account_token = (try? values.decode(String.self, forKey: .account_token)) ?? nil
        msg = (try? values.decode(String.self, forKey: .msg)) ?? nil
        nickname = (try? values.decode(String.self, forKey: .nickname)) ?? nil
    }
}
