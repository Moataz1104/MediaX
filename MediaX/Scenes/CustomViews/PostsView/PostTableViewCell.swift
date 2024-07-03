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
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var imageLoadDisposable: Disposable?
    var userImageLoadDisposable: Disposable?
    var viewModel:HomeViewModel?
    var post:PostModel?
    
    var postIndex:Int?

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
        
        userImageLoadDisposable?.dispose()
        userImage.image = nil

        
        postIndex = nil

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
    }
//    MARK: - Actions
    
    @IBAction func likeButtonAction(_ sender: Any) {
        
        if let post = post , let postIndex = postIndex{
            let id = String(describing: post.id!)
            viewModel?.likeButtonSubject.accept(id)
            viewModel?.fetchOnePost(by: "\(id)", index: postIndex)
            
            
        }
    }
    @IBAction func commentButtonAction(_ sender: Any) {
        print("comment Button")
        

    }
    
    func configureCell(with post: PostModel, accessToken: String) {
        if let imageUrlString = post.image, let url = URL(string: imageUrlString) {
            imageLoadDisposable = postImage.loadImage(url: url, accessToken: accessToken,indicator:indicator)
            
        }
        
        if let userImageString = post.userImage, let url = URL(string: userImageString) {
            userImageLoadDisposable = userImage.loadImage(url: url, accessToken: accessToken, indicator: nil)
            
        }

        
        userName.text = post.username ?? "No user name"
        postContent.text = post.content ?? "No Content"
        numberOfLikesLabel.text = "Liked by \(post.numberOfLikes ?? -1)"
        postTime.text = post.timeAgo ?? ""
        if post.liked!{
            likeButton.setImage(UIImage.systemImage(named: "heart.fill", withSymbolConfiguration: .large), for: .normal)

        }else{ 
            likeButton.setImage(UIImage.systemImage(named: "heart", withSymbolConfiguration: .large), for: .normal)

        }
    }
}

