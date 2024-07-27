//
//  UserInfoCollectionViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 12/07/2024.
//

import UIKit
import RxSwift
import RxCocoa
class UserInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "UserInfoCollectionViewCell"
    
    @IBOutlet weak var backImageView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postsNumLabel: UILabel!
    @IBOutlet weak var followersNumLabel: UILabel!
    @IBOutlet weak var followingNumLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var userImageDisposable : Disposable?
    var viewModel:ProfileViewModel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageDisposable?.dispose()
        userImage.image = nil
    }
    
    @IBAction func followButtonAction(_ sender: Any) {
        viewModel?.followButtonRelay.accept(())
    }
    
    
    private func configUi(){
        
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        
        backImageView.layer.cornerRadius = backImageView.bounds.width / 2
        backImageView.clipsToBounds = true
        backImageView.layer.borderWidth = 2
        backImageView.layer.borderColor = UIColor.main.cgColor

        
        followButton.layer.cornerRadius = followButton.frame.height / 2
        followButton.isHidden = true
    }
    
    
    func configureCell(with user:UserModel,isFollowButtonHidden:Bool){
        
        if let stringUrl = user.image,
           let url = URL(string: stringUrl){
            userImageDisposable = userImage.loadImage(url: url, indicator: nil)
        }
        DispatchQueue.main.async{[weak self] in
            self?.postsNumLabel.text = "\(user.numberOfPosts ?? 0)"
            self?.followersNumLabel.text = "\(user.numberOfFollowers ?? 0)"
            self?.followingNumLabel.text = "\(user.numberOfFollowing ?? 0)"
            self?.userName.text = user.fullName ?? ""
            self?.userBio.text = user.bio
            self?.checkFollowStatus(status: user.followStatus ?? "",isFollowButtonHidden:isFollowButtonHidden)
        }
    }
    
    
    private func checkFollowStatus(status:String,isFollowButtonHidden:Bool){
        if status == "NONE"{
            followButton.backgroundColor = .main
            followButton.setTitle("Follow", for: .normal)
            followButton.isHidden = isFollowButtonHidden

        }else{
            followButton.backgroundColor = .lightGray
            followButton.setTitle("UnFollow", for: .normal)
            followButton.isHidden = isFollowButtonHidden

        }
        
    }

}
