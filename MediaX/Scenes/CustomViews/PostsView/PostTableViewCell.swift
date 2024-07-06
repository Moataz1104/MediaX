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
    @IBOutlet weak var bigHeartImage: UIImageView!
    
    var imageLoadDisposable: Disposable?
    var userImageLoadDisposable: Disposable?
    var viewModel:HomeViewModel?
    var post:PostModel?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()
        setUpDoupleTapRecognaizer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadDisposable?.dispose()
        postImage.image = nil
        
        userImageLoadDisposable?.dispose()
        userImage.image = nil

        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
    }
    
    
    
//    MARK: - Actions
    
    @IBAction func likeButtonAction(_ sender: Any) {
                
        if let post = post{
            let id = String(describing: post.id!)
            viewModel?.likeButtonSubject.accept(id)
        }
        
    }
    @IBAction func commentButtonAction(_ sender: Any) {
        if let post = post{
            viewModel?.showCommentsScreen(post:post)
        }
    }
    @objc func doubletapLike() {
        if !(post?.liked)!{
            bigHeartImage.isHidden = false
            bigHeartImage.alpha = 1
            bigHeartImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {[weak self] in
                self?.bigHeartImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (completed) in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {[weak self] in
                    self?.bigHeartImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }) { (completed) in
                    UIView.animate(withDuration: 0.2, delay: 0.5, options: [.curveEaseInOut], animations: {[weak self] in
                        self?.bigHeartImage.alpha = 0
                    }) {[weak self] (completed) in
                        self?.bigHeartImage.isHidden = true
                    }
                }
            }
        }

        if let post = post {
            let id = String(describing: post.id!)
            viewModel?.likeButtonSubject.accept(id)
        }
    }
//    MARK: - PRivates
    private func setUpDoupleTapRecognaizer(){
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubletapLike))

        doubleTapRecognizer.numberOfTapsRequired = 2
        postImage.addGestureRecognizer(doubleTapRecognizer)
        postImage.isUserInteractionEnabled = true

    }
    private func configUi(){
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true

        postImage.layer.cornerRadius = 25
        
        contentView.layer.cornerRadius = 25
        
        backgroundColor = .backGroundMain
        
        contentView.bringSubviewToFront(bigHeartImage)

    }

    func configureCell(with post: PostModel, accessToken: String) {
        if let imageUrlString = post.image, let url = URL(string: imageUrlString) {
            imageLoadDisposable = postImage.loadImage(url: url, accessToken: accessToken,indicator:indicator)
            
        }
        
        if let userImageString = post.userImage, let url = URL(string: userImageString) {
            DispatchQueue.main.async{[weak self] in
                UIView.transition(with: self?.userImage ?? UIImageView(), duration: 0.5,options: .transitionCrossDissolve) {
                    self?.imageLoadDisposable = self?.userImage.loadImage(url: url, accessToken: accessToken, indicator: nil)
                        
                }
            }

        }

        
        userName.text = post.username ?? "No user name"
        postContent.text = post.content ?? "No Content"
        numberOfLikesLabel.text = "Liked by \(post.numberOfLikes ?? -1)"
        postTime.text = post.timeAgo ?? ""
        
        if post.liked!{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.likeButton.setImage(UIImage.systemImage(named: "heart.fill", withSymbolConfiguration: .large), for: .normal)

            }

        }else{ 
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.likeButton.setImage(UIImage.systemImage(named: "heart", withSymbolConfiguration: .large), for: .normal)

            }

        }
        
    }
}

