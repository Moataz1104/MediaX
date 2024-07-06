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

    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var commentTime: UILabel!
    @IBOutlet weak var content: TopAlignedLabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var contentLabelHeightCons: NSLayoutConstraint!
    
    var isShrink = false
    var userImageDisposable : Disposable?
    var viewModel : CommentsViewModel?
    
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
        if let viewModel = viewModel{
            DispatchQueue.main.async{[weak self] in
                
                UIView.transition(with: self?.userImage ?? UIImageView(), duration: 0.5,options: .transitionCrossDissolve) {
                    self?.userImageDisposable = self?.userImage.loadImage(url: URL(string:comment.userImage!)!, accessToken: viewModel.accessToken!, indicator: nil)
                        
                }
            }
        }
        
        userName.text = comment.username ?? ""
        content.text = comment.content ?? ""
        commentTime.text = comment.timeAgo ?? ""
        
        if comment.liked!{
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




