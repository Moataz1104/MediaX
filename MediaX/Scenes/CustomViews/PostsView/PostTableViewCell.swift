//
//  PostTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 30/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var imageLoadDisposable: Disposable?

    override func awakeFromNib() {
        super.awakeFromNib()

        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true

        postImage.layer.cornerRadius = 25
        
        contentView.layer.cornerRadius = 25
        
        backgroundColor = .backGroundMain
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadDisposable?.dispose()
        postImage.image = nil
        indicator.startAnimating()
        indicator.isHidden = false

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
    }
    
    func configureCell(with post: PostModel, accessToken: String) {
        if let imageUrlString = post.imageUrlString, let url = URL(string: imageUrlString) {
            imageLoadDisposable = postImage.loadImage(url: url, accessToken: accessToken,indicator:indicator)
            
        }
        
        userName.text = post.username ?? "No user name"
        postContent.text = post.content ?? "No Content"
    }
}
