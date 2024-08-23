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
    
    
    var disposeBag = DisposeBag()
    weak var viewModel:ProfileViewModel?
    var user : UserModel?
    var isFollow:Bool?
    let followRelay = PublishRelay<Bool>()


    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()

        handleFollowerStackGesture()
        handleFollowingStackGesture()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
        disposeBag = DisposeBag()
    }
    
    @IBAction func followButtonAction(_ sender: Any) {
        viewModel?.followButtonRelay.accept(())
        isFollow?.toggle()
        followRelay.accept(isFollow!)

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
            userImage.loadImage(url: url, indicator: nil)
                .disposed(by: disposeBag)
        }
        DispatchQueue.main.async{[weak self] in
            guard let self = self else{return}
            self.postsNumLabel.text = "\(user.numberOfPosts ?? 0)"
            self.followersNumLabel.text = "\(user.numberOfFollowers ?? 0)"
            self.followingNumLabel.text = "\(user.numberOfFollowing ?? 0)"
            self.userName.text = user.fullName ?? ""
            self.userBio.text = user.bio
            self.checkFollowStatus(followStatus: user.follow ,isFollowButtonHidden:isFollowButtonHidden)
            
            self.isFollow = user.follow
            
        }
        
        followRelay
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: {[weak self] isFollow in
                self?.checkFollowStatus(followStatus: isFollow, isFollowButtonHidden: isFollowButtonHidden)
                
                if isFollow{
                    self?.followersNumLabel.text = "\((user.numberOfFollowers!) + 1)"
                }else{
                    self?.followersNumLabel.text = "\((user.numberOfFollowers!) - 1)"
                }

            })
            .disposed(by: disposeBag)

    }
    
    
    private func checkFollowStatus(followStatus:Bool?,isFollowButtonHidden:Bool){
        
        
        if let followStatus = followStatus{
            if !followStatus{
                followButton.backgroundColor = .main
                followButton.setTitle("Follow", for: .normal)
                followButton.isHidden = isFollowButtonHidden
                
            }else{
                followButton.backgroundColor = .lightGray
                followButton.setTitle("UnFollow", for: .normal)
                followButton.isHidden = isFollowButtonHidden
                
            }
        }else{
            followButton.isHidden = true
        }
    }

}
