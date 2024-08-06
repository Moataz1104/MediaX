//
//  NotificationTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 06/08/2024.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    static let identifier = "NotificationTableViewCell"
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var notifiMessage: UILabel!
    @IBOutlet weak var isReadView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        isReadView.layer.cornerRadius = isReadView.bounds.width / 2
        isReadView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
