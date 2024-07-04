//
//  CommentTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 03/07/2024.
//

import UIKit

protocol CommentCellDelegate:AnyObject{
    func commentCellHeightDidChange(_ height:CGFloat,at indexPath: IndexPath)
}


class CommentTableViewCell: UITableViewCell {
    static let identifier = "CommentTableViewCell"
    
    weak var delegate : CommentCellDelegate?
    var indexPath : IndexPath?

    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var commentTime: UILabel!
    @IBOutlet weak var content: TopAlignedLabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var contentLabelHeightCons: NSLayoutConstraint!
    
    var isShrink = false
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
        
        setupTapGesture()
    }
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentLabelTapped))
        content.isUserInteractionEnabled = true
        content.addGestureRecognizer(tapGesture)
    }
    
    @objc private func contentLabelTapped() {
        calculateTextHeight(text: content.text!, width: content.bounds.width)
    }
    
    func calculateTextHeight(text: String, font: UIFont = UIFont.systemFont(ofSize: 14), width: CGFloat) {
        
        isShrink.toggle()
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = NSString(string: text).boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        
        print(boundingRect.height)
        if boundingRect.height > 80{
            if let indexPath = indexPath {
                if isShrink{
                    delegate?.commentCellHeightDidChange(ceil(boundingRect.height) + 40, at: indexPath)
                    contentLabelHeightCons.constant = boundingRect.height
                    print("done")
                }else{
                    delegate?.commentCellHeightDidChange(100, at: indexPath)
                    contentLabelHeightCons.constant = 50

                }
            }

        }
    }


}




