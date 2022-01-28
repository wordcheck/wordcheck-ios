import UIKit
import Alamofire

class papagoViewController: UIViewController {
    @IBOutlet weak var targetInput: UITextField!
    @IBOutlet weak var result: UILabel!
    
    let url = "https://openapi.naver.com/v1/papago/n2mt"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPapagoUI()
    }
    
    func setPapagoUI() {
        title = "파파고 번역기"
        
        targetInput.layer.borderWidth = 1
        targetInput.layer.borderColor = UIColor.systemIndigo.cgColor
        targetInput.layer.cornerRadius = 16

        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor.systemIndigo.cgColor
        result.layer.cornerRadius = 16
    }
}

extension papagoViewController: UITextFieldDelegate {
//    @objc private func adjustInputView(noti: Notification) {
//        guard let userInfo = noti.userInfo else { return }
//        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//
//        if noti.name == UIResponder.keyboardWillShowNotification {
//            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
//            answerInputBottom.constant = adjustmentHeight
//            buttonBottom.constant = answerInputBottom.constant + answerInput.frame.height + 20
//        } else {
//            answerInputBottom.constant = 120
//            buttonBottom.constant = 370
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        targetInput.resignFirstResponder()
        
        let parameters: Parameters = [
            "source": "en",
            "target": "ko",
            "text": targetInput.text ?? ""
        ]
        let header: HTTPHeaders = [
            "Content-Type":"application/x-www-form-urlencoded; charset=UTF-8",
            "X-Naver-Client-Id":"hqtqjdo_7Yd9AIdGZ8li",
            "X-Naver-Client-Secret":"feNrOUUQv9"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: header).responseDecodable(of: PapagoResult.self) { response in
            switch response.result {
            case .success:
                guard let papago = response.value?.message?.result.translatedText else { return }
                self.result.text = papago
            case .failure:
                return
            }
        }
        return true
    }
}
