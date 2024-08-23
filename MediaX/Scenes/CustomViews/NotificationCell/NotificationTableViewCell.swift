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
    
    
    var disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        postImage.layer.cornerRadius = 8
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImage.image = nil
        userImage.image = nil
        disposeBag = DisposeBag()
        
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
            userImage.loadImage(url: userImageURL, indicator: nil)
                .disposed(by: disposeBag)
        }
        
        if let postImageStr = notification.postImage,
           let postImageURL = URL(string: postImageStr) {
            postImage.loadImage(url: postImageURL, indicator: nil)
                .disposed(by: disposeBag)
        }
    }

}
