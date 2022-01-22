import UIKit
import Kingfisher
import Alamofire

class userProfileViewController: UITableViewController {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var nickNameFix: UITextField!
    @IBOutlet weak var fixButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let token = Storage.retrive("account_token.json", from: .documents, as: String.self) ?? ""
    var userProfile = Storage.retrive("user_info.json", from: .documents, as: User.self)
    let normalMenu = ["북마크 단어", "건의사항"]
    let accountMenu = ["로그아웃"]
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUser()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                print("북마크")
            case 1:
                print("건의사항")
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                let alert = UIAlertController(title: "알림", message: "로그아웃 되었습니다", preferredStyle: UIAlertController.Style.alert)
                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                    Storage.clear(.documents)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                alert.addAction(confirm)
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
        default:
            break
        }
    }
    
    func setUser() {
        guard let userProfile = userProfile else { return }
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.lightGray.cgColor
        userImage.layer.cornerRadius = 32
        let url = URL(string: (userProfile.profile_image)!)
        userImage.kf.setImage(with: url)
        userNickname.text = userProfile.nickname
        nickNameFix.isHidden = true
        confirmButton.isHidden = true
        cancelButton.isHidden = true
        let updatePhotoButton = UITapGestureRecognizer(target: self, action: #selector(photoClick))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(updatePhotoButton)
        imagePickerController.delegate = self
    }
    
    @objc func photoClick(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "프로필 사진 변경", message: "", preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "앨범에서 선택", style: .default) { action in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let normal = UIAlertAction(title: "기본 이미지", style: .default) { action in
            let header: HTTPHeaders = [
                "Authorization": self.token
            ]
            let parameters: Parameters = [
                "profile_image": "/media/default.jpeg"
            ]

            AF.request("http://52.78.37.13/api/accounts/profile/", method: .patch, parameters: parameters, headers: header).validate(statusCode: 200..<300).responseDecodable(of: User.self) { response in
                switch response.result {
                case .success:
                    guard let image = response.value?.profile_image else { return }
                    self.userProfile?.profile_image = image
                    Storage.store(self.userProfile, to: .documents, as: "user_info.json")
                    self.userImage.kf.setImage(with: URL(string: (image)))
                    self.tableView.reloadData()
                default:
                    return
                }
            }
        }
        let cancle = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library)
        alert.addAction(normal)
        alert.addAction(cancle)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func updateNickname(_ sender: Any) {
        userNickname.isHidden = true
        nickNameFix.isHidden = false
        confirmButton.isHidden = false
        cancelButton.isHidden = false
        nickNameFix.backgroundColor = .clear
        nickNameFix.text = userProfile?.nickname
        fixButton.isHidden = true
        self.nickNameFix.becomeFirstResponder()
    }
    
    @IBAction func confirmUpdate(_ sender: Any) {
        if nickNameFix.text?.count != 0 {
            let header: HTTPHeaders = [
                "Authorization": self.token
            ]
            let parameters: Parameters = [
                "nickname": nickNameFix.text!
            ]

            AF.request("http://52.78.37.13/api/accounts/profile/", method: .patch, parameters: parameters, headers: header).validate(statusCode: 200..<300).responseDecodable(of: User.self) { response in
                switch response.result {
                case .success:
                    guard let nickname = response.value?.nickname else { return }
                    let alert = UIAlertController(title: "알림", message: "닉네임이 변경되었습니다", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { action in
                        self.userNickname.isHidden = false
                        self.nickNameFix.isHidden = true
                        self.fixButton.isHidden = false
                        self.confirmButton.isHidden = true
                        self.cancelButton.isHidden = true
                        self.userProfile?.nickname = nickname
                        Storage.store(self.userProfile, to: .documents, as: "user_info.json")
                        self.userNickname.text = nickname
//                        self.nickNameFix.endEditing(true)
                        self.tableView.reloadData()
                    }
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                    
                default:
                    let alert = UIAlertController(title: "알림", message: "중복된 닉네임입니다", preferredStyle: UIAlertController.Style.alert)
                    let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "알림", message: "닉네임은 최소 한 글자 이상입니다", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelUpdate(_ sender: Any) {
        userNickname.isHidden = false
        nickNameFix.isHidden = true
        fixButton.isHidden = false
        confirmButton.isHidden = true
        cancelButton.isHidden = true
        self.nickNameFix.endEditing(true)
    }
}

// 푸덕 이미지 --> "/media/default.jpeg"
extension userProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        let imageData = image.jpegData(compressionQuality: 0.5)
        let header: HTTPHeaders = [
            "Authorization": token
            ]

        AF.upload(multipartFormData: { MultipartFormData in
            if imageData != nil {
                MultipartFormData.append(imageData!, withName: "profile_image", fileName: "profileImage.jpeg", mimeType: "image/jpeg")
            }
        }, to: "http://52.78.37.13/api/accounts/profile/", method: .patch, headers: header).validate(statusCode: 200..<300).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success:
                guard let myImage = response.value?.profile_image else { return }
                self.userProfile?.profile_image = myImage
                Storage.store(self.userProfile, to: .documents, as: "user_info.json")
                self.userImage.kf.setImage(with: URL(string: (myImage)))
                self.tableView.reloadData()
            default:
                break
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension userProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nickNameFix.resignFirstResponder()
        return true
    }
}
