//
//  PostTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 30/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Hero


class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var bottomUserName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var bigHeartImage: UIImageView!
    
    var imageLoadDisposable: Disposable?
    var userImageLoadDisposable: Disposable?
    var viewModel:PostsViewModel?
    var post:PostModel?
    var indexPath:IndexPath?
    weak var delegate:HomeViewDelegate?
    var isLiked:Bool?

    var likeSubscription:Disposable?
    let likeRelay = PublishRelay<Bool>()

    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()
        setUpDoupleTapRecognaizer()
        setUpUserImageGesture()
        setGestureForCommentLabel()
        setUpNumberOfLikesGesture()
        if let indexPath = indexPath{
            postImage.heroID = "\(indexPath.row)"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadDisposable?.dispose()
        postImage.image = nil
        
        userImageLoadDisposable?.dispose()
        userImage.image = nil
        
        likeSubscription?.dispose()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
    }
    
    
    
    //    MARK: - Actions
    
    @IBAction func likeButtonAction(_ sender: Any) {
        
        if let post = post , let indexPath = indexPath{
            let id = String(describing: post.id!)
            isLiked?.toggle()
            likeRelay.accept(isLiked!)
            viewModel?.likeButtonSubject.accept((id,indexPath))
        }
        
    }
    @IBAction func commentButtonAction(_ sender: Any) {
        if let post = post{
            viewModel?.showCommentsScreen(post:post)            
        }
    }
    @objc func doubletapLike() {
        if let _ = post?.liked{
            bigHeartImage.isHidden = false
            bigHeartImage.alpha = 1
            bigHeartImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            DispatchQueue.main.async{[weak self] in
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                    self?.bigHeartImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                }) { (completed) in
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                        self?.bigHeartImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }) { (completed) in
                        UIView.animate(withDuration: 0.2, delay: 0.5, options: [.curveEaseInOut], animations: {
                            self?.bigHeartImage.alpha = 0
                        }) { (completed) in
                            self?.bigHeartImage.isHidden = true
                        }
                    }
                }
            }
        }

        if let post = post,let indexPath = indexPath {
            let id = String(describing: post.id!)
            isLiked?.toggle()
            likeRelay.accept(isLiked!)
            viewModel?.likeButtonSubject.accept((id,indexPath))
        }
    }
    
    @objc func handleUserImageTap(){
        if let post = post{
            viewModel?.showOtherUserScreen(id:"\(post.userId!)")
            delegate?.didScrollUp()
        }
    }
    
    @objc func commentLabelAction(){
        if let post = post{
            viewModel?.showCommentsScreen(post:post)
        }

    }
    
    @objc func numberOfLikesLabelAction(){
        if let post = post{
            viewModel?.showLikesScreen(users: post.likeResponseDtos!)
        }
    }

    //    MARK: - Privates
    private func setUpDoupleTapRecognaizer(){
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubletapLike))
        
        doubleTapRecognizer.numberOfTapsRequired = 2
        postImage.addGestureRecognizer(doubleTapRecognizer)
        postImage.isUserInteractionEnabled = true
        
    }
    private func setUpUserImageGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUserImageTap))
        userImage.addGestureRecognizer(tapGesture)
        userImage.isUserInteractionEnabled = true
    }
    private func configUi(){
        settingButton.isHidden = true
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        postImage.layer.cornerRadius = 25
        contentView.layer.cornerRadius = 25
        backgroundColor = .backGroundMain
        contentView.bringSubviewToFront(bigHeartImage)
        
        indicator.isHidden = true
        indicator.stopAnimating()
        
    }
    
    private func setGestureForCommentLabel(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(commentLabelAction))
        numberOfCommentsLabel.addGestureRecognizer(gesture)
        numberOfCommentsLabel.isUserInteractionEnabled = true
    }
    
    private func setUpNumberOfLikesGesture(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(numberOfLikesLabelAction))
        numberOfLikesLabel.addGestureRecognizer(gesture)
        numberOfLikesLabel.isUserInteractionEnabled = true
    }
    
//    MARK: - Configuration
    func configureCell(with post: PostModel) {
        
        if let imageUrlString = post.image, let url = URL(string: imageUrlString) {
            DispatchQueue.main.async{[weak self] in
                self?.imageLoadDisposable = self?.postImage.loadImage(url: url,indicator:self?.indicator)
            }
        }
        
        if let userImageString = post.userImage, let url = URL(string: userImageString) {
            DispatchQueue.main.async{[weak self] in
                UIView.transition(with: self?.userImage ?? UIImageView(), duration: 0.5,options: .transitionCrossDissolve) {
                    self?.userImageLoadDisposable = self?.userImage.loadImage(url: url, indicator: nil)
                }
            }
            
        }
        DispatchQueue.main.async{[weak self] in
            self?.userName.text = post.username ?? "No user name"
            self?.numberOfLikesLabel.text = "\(post.numberOfLikes ?? -1) Likes"
            if let count = post.numberOfComments{
                if count == 0{
                    self?.numberOfCommentsLabel.isHidden = true
                }else{
                    self?.numberOfCommentsLabel.isHidden = false
                    self?.numberOfCommentsLabel.text = "View all \(count) Comments"

                }
            }
            if let content = post.content{
                if content == " "{
                    self?.postContent.isHidden = true
                    self?.bottomUserName.isHidden = true
                }else{
                    self?.postContent.isHidden = false
                    self?.bottomUserName.isHidden = false
                    self?.bottomUserName.text = post.username ?? "No user name"
                    self?.postContent.text = post.content ?? "No Content"

                }
            }
            self?.postTime.text = post.timeAgo ?? ""
            
            self?.checkForLikeStatus(status: post.liked!)
            
            self?.isLiked = post.liked!
            self?.likeSubscription = self?.likeRelay
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { isLiked in
                    self?.checkForLikeStatus(status: isLiked)
                    
                    if isLiked{
                        self?.numberOfLikesLabel.text = "\(post.numberOfLikes! + 1) Likes"
                    }else{
                        self?.numberOfLikesLabel.text = "\(post.numberOfLikes! - 1) Likes"
                    }
                })


        }
        
    }
    
    
    private func checkForLikeStatus(status:Bool){
        if status{
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

