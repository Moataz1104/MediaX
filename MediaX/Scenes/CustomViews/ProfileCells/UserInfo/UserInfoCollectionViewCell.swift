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
    @IBOutlet weak var followersStack: UIStackView!
    @IBOutlet weak var followingStack: UIStackView!
    
    
    var userImageDisposable : Disposable?
    var viewModel:ProfileViewModel?
    var user : UserModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()

        handleFollowerStackGesture()
        handleFollowingStackGesture()
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
    
    private func handleFollowerStackGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(followerStacksTapAction))
        
        followersStack.addGestureRecognizer(tapGesture)
        followersStack.isUserInteractionEnabled = true
    }
    private func handleFollowingStackGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(followingStacksTapAction))
        
        followingStack.addGestureRecognizer(tapGesture)
        followingStack.isUserInteractionEnabled = true
    }

    
    @objc func followerStacksTapAction(){
        if let user = user{
            viewModel?.followerDetailsRelay.accept("\(user.id!)")
        }
    }
    @objc func followingStacksTapAction(){
        if let user = user{
            viewModel?.followingDetailsRelay.accept("\(user.id!)")
        }
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
            self?.checkFollowStatus(status: user.follow ?? false,isFollowButtonHidden:isFollowButtonHidden)
        }
    }
    
    
    private func checkFollowStatus(status:Bool,isFollowButtonHidden:Bool){
        if !status{
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
