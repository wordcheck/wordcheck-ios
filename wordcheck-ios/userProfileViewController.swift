import UIKit
import Kingfisher

class userProfileViewController: UITableViewController {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNickname: UILabel!
    
    var userProfile = Storage.retrive("user_info.json", from: .documents, as: User.self)
    let normalMenu = ["북마크 단어", "건의사항"]
    let accountMenu = ["로그아웃"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUser()
    }

    func setUser() {
        guard let userProfile = userProfile else { return }
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.lightGray.cgColor
        userImage.layer.cornerRadius = 32
        let url = URL(string: (userProfile.profile_image)!)
        userImage.kf.setImage(with: url)
        userNickname.text = userProfile.nickname
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.section), \(indexPath.row)")
    }
}
