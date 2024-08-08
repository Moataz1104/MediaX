//
//  CommentTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 03/07/2024.
//

import UIKit
import RxSwift
import RxCocoa

protocol CommentCellDelegate:AnyObject{
    func commentCellHeightDidChange(_ height:CGFloat,at indexPath: IndexPath)
}


class CommentTableViewCell: UITableViewCell {
    static let identifier = "CommentTableViewCell"
    
//    MARK: - Attributs
    weak var delegate : CommentCellDelegate?
    var indexPath : IndexPath?
    var isShrink = false
    var userImageDisposable : Disposable?
    var viewModel : CommentsViewModel?
    var comment:CommentModel?
    var isLiked:Bool?
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var numberOfLikes: UILabel!
    @IBOutlet weak var commentTime: UILabel!
    @IBOutlet weak var content: TopAlignedLabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var contentLabelHeightCons: NSLayoutConstraint!
    
    var likeSubscription:Disposable?
    let likeRelay = PublishRelay<Bool>()
//    MARK: - Cell life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
        
        setupTapGesture()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageDisposable?.dispose()
        likeSubscription?.dispose()
    }
    
    
//    MARK: - Actions
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentLabelTapped))
        content.isUserInteractionEnabled = true
        content.addGestureRecognizer(tapGesture)
    }
    
    @objc private func contentLabelTapped() {
        calculateTextHeight(text: content.text!, width: content.bounds.width)
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        if let comment = comment , let indexPath = indexPath{
            isLiked?.toggle()
            likeRelay.accept(isLiked!)
            viewModel?.likeButtonRelay.accept(("\(comment.id!)",indexPath))
        }
    }
    
    
//    MARK: - Privates
    private func calculateTextHeight(text: String, font: UIFont = UIFont.systemFont(ofSize: 14), width: CGFloat) {
        
        isShrink.toggle()
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = NSString(string: text).boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        
        
        if boundingRect.height > 30{
            if let indexPath = indexPath {
                if isShrink{
                    delegate?.commentCellHeightDidChange(ceil(boundingRect.height) + 40, at: indexPath)
                    
                    UIView.animate(withDuration: 0.3) {[weak self] in
                        self?.contentLabelHeightCons.constant = boundingRect.height
                        self?.layoutIfNeeded()
                    }
                    print("done")
                }else{
                    delegate?.commentCellHeightDidChange(90, at: indexPath)
                    UIView.animate(withDuration: 0.3) {[weak self] in
                        self?.contentLabelHeightCons.constant = 30
                        self?.layoutIfNeeded()
                    }

                }
            }

        }
    }
    
    
//    MARK: - Configuration
    func configureCell(with comment : CommentModel){
        
        DispatchQueue.main.async{[weak self] in
            UIView.transition(with: self?.userImage ?? UIImageView(), duration: 0.1,options: .transitionCrossDissolve) {
                self?.userImageDisposable = self?.userImage.loadImage(url: URL(string:comment.userImage!)!, indicator: nil)
                    
            }
        }

        DispatchQueue.main.async{[weak self] in
            self?.userName.text = comment.username ?? ""
            self?.content.text = comment.content ?? ""
            self?.commentTime.text = comment.timeAgo ?? ""
            self?.numberOfLikes.text = "\(comment.numberOfLikes!)"

            self?.checkForLikeStatus(status: comment.liked!)

            self?.isLiked = comment.liked!
            
            self?.likeSubscription = self?.likeRelay
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { isLiked in
                    self?.checkForLikeStatus(status: isLiked)
                    if isLiked{
                        self?.numberOfLikes.text = "\(comment.numberOfLikes! + 1)"
                    }else{
                        self?.numberOfLikes.text = "\(comment.numberOfLikes! - 1)"
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




