//
//  UserInfoCollectionViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 12/07/2024.
//

import UIKit

class UserInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "UserInfoCollectionViewCell"
    
    @IBOutlet weak var backImageView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postsNumLabel: UILabel!
    @IBOutlet weak var followersNumLabel: UILabel!
    @IBOutlet weak var followingNumLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userBio: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        
        backImageView.layer.cornerRadius = backImageView.bounds.width / 2
        backImageView.clipsToBounds = true
        backImageView.layer.borderWidth = 2
        backImageView.layer.borderColor = UIColor.main.cgColor


    }

}
