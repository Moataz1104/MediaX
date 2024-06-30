//
//  PostTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 30/06/2024.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true

        postImage.layer.cornerRadius = 25
        
        contentView.layer.cornerRadius = 25
        
        backgroundColor = .backGroundMain
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
    }

    
}
