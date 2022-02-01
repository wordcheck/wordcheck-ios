import UIKit
import Alamofire
import AVFoundation

class papagoViewController: UIViewController {
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var targetInput: UITextField!
    @IBOutlet weak var result: UILabel!
  
    let url = "https://openapi.naver.com/v1/papago/n2mt"
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPapagoUI()
    }
    
    func setPapagoUI() {
        title = "파파고 번역기"
        
        targetInput.layer.borderWidth = 1
        targetInput.layer.borderColor = UIColor.lightGray.cgColor
        targetInput.layer.cornerRadius = 16

        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor.lightGray.cgColor
        result.layer.cornerRadius = 16
    }
    
    @IBAction func languageChange(_ sender: Any) {
        if targetLabel.text == "영어" {
            targetLabel.text = "한국어"
            resultLabel.text = "영어"
        } else {
            targetLabel.text = "영어"
            resultLabel.text = "한국어"
        }
    }
    
    @IBAction func targetSpeech(_ sender: Any) {
        if targetLabel.text == "영어" {
            setSpeechLanguage(targetInput.text!, "en-US")
        } else {
            setSpeechLanguage(targetInput.text!, "ko-KR")
        }
    }
    
    @IBAction func resultSpeech(_ sender: Any) {
        if resultLabel.text == "영어" {
            setSpeechLanguage(result.text!, "en-US")
        } else {
            setSpeechLanguage(result.text!, "ko-KR")
        }
    }
    
    func setSpeechLanguage(_ string: String, _ language: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        self.synthesizer.speak(utterance)
    }
    
    @IBAction func createButton(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "wordsCreateViewController") as? wordsCreateViewController else { return }
        vc.modalTransitionStyle = .coverVertical
        vc.spelling = targetInput.text ?? ""
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func touchView(_ sender: Any) {
        targetInput.resignFirstResponder()
    }
}

extension papagoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        targetInput.resignFirstResponder()
        var targetLanguage = "en"
        var resultLanguage = "ko"
        if targetLabel.text == "영어" {
            targetLanguage = "en"
            resultLanguage = "ko"
        } else {
            targetLanguage = "ko"
            resultLanguage = "en"
        }
        
        let parameters: Parameters = [
            "source": targetLanguage,
            "target": resultLanguage,
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
