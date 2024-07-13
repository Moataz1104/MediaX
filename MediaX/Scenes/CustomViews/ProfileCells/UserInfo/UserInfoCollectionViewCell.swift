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
    
    var userImageDisposable : Disposable?
    var viewModel:ProfileViewModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        
        backImageView.layer.cornerRadius = backImageView.bounds.width / 2
        backImageView.clipsToBounds = true
        backImageView.layer.borderWidth = 2
        backImageView.layer.borderColor = UIColor.main.cgColor


    }
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageDisposable?.dispose()
        userImage.image = nil
    }
    
    
    func configureCell(with user:UserModel){
        
        if let stringUrl = user.image,
           let url = URL(string: stringUrl),
           let token = viewModel?.accessToken{
            userImageDisposable = userImage.loadImage(url: url, accessToken: token, indicator: nil)            
        }
        DispatchQueue.main.async{[weak self] in
            self?.postsNumLabel.text = "\(user.numberOfPosts ?? 0)"
            self?.followersNumLabel.text = "\(user.numberOfFollowers ?? 0)"
            self?.followingNumLabel.text = "\(user.numberOfFollowing ?? 0)"
            self?.userName.text = user.fullName ?? ""
            self?.userBio.text = user.bio
        }
    }

}