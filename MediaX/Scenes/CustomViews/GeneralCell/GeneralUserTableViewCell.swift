//
//  GeneralUserTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 27/07/2024.
//

import UIKit
import RxSwift
import RxCocoa

class GeneralUserTableViewCell: UITableViewCell {
    static let identifier = "GeneralUserTableViewCell"

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var imageLoadDisposable:Disposable?
    var searchViewModel : SearchViewModel?
    var generalUsersViewModel : GeneralUsersViewModel?
    var user:UserModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.layer.cornerRadius = followButton.frame.height / 2
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
        timeLabel.isHidden = true
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
    @IBAction func followButtonAction(_ sender: Any) {
        if let vm = searchViewModel, let id = user?.id{
            vm.followButtonRelay.accept("\(id)")
        }else if let vm = generalUsersViewModel , let id = user?.id{
            vm.followButtonRelay.accept("\(id)")
        }
    }
    
 
    
    
    func configureUser(user:UserModel){
        
        DispatchQueue.main.async{[weak self] in
            self?.userName.text = user.fullName ?? ""
            self?.checkFollowStatus(followStatus: user.follow)
            
            if let timeAgo = user.timeAgo{
                self?.timeLabel.isHidden = false
                self?.timeLabel.text = timeAgo
            }
        }
        
        if let urlString = user.image , let url = URL(string: urlString){
            imageLoadDisposable = userImage.loadImage(url: url, indicator: nil)
        }
        
        
    }
    
    private func checkFollowStatus(followStatus:Bool?){
        
        
        if let followStatus = followStatus{
            if !followStatus{
                followButton.backgroundColor = .main
                followButton.setTitle("Follow", for: .normal)
            }else{
                followButton.backgroundColor = .lightGray
                followButton.setTitle("UnFollow", for: .normal)
            }
        }else{
            followButton.isHidden = true
        }
    }


}
