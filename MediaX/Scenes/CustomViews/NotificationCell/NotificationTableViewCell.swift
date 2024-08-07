//
//  NotificationTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 06/08/2024.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationTableViewCell: UITableViewCell {
    static let identifier = "NotificationTableViewCell"
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var notifiMessage: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var userImageDisposable:Disposable?
    var postImageDisposable:Disposable?
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        postImage.layer.cornerRadius = 8
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageDisposable?.dispose()
        postImage.image = nil
        userImageDisposable?.dispose()
        userImage.image = nil
        
        self.backgroundColor = .clear

    }
    
    func configureCell(with notification: NotificationModel) {
        DispatchQueue.main.async { [weak self] in
            self?.notifiMessage.text = notification.notificationMessage
            self?.timeLabel.text = notification.timeAgo
            
            
            if notification.read ?? false {
                self?.backgroundColor = UIColor.clear
            } else {
                self?.backgroundColor = UIColor.main.withAlphaComponent(0.2)
            }
        }
        
        
        if let fromUserImage = notification.fromUserImage,
           let userImageURL = URL(string: fromUserImage) {
            userImageDisposable = userImage.loadImage(url: userImageURL, indicator: nil)
        }
        
        if let postImageStr = notification.postImage,
           let postImageURL = URL(string: postImageStr) {
            postImageDisposable = postImage.loadImage(url: postImageURL, indicator: nil)
        }
    }

}
