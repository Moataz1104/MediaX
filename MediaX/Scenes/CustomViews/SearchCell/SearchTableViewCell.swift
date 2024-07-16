//
//  SearchTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 16/07/2024.
//

import UIKit
import RxSwift
import RxCocoa
class SearchTableViewCell: UITableViewCell {
    static let identifier = "SearchTableViewCell"
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    var imageLoadDisposable:Disposable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadDisposable?.dispose()
        userImage.image = nil
    }
    
    @IBAction func xButtonAction(_ sender: Any) {
    }
 
    
    
    func configureUser(user:UserModel){
        
        DispatchQueue.main.async{[weak self] in
            self?.userName.text = user.fullName ?? ""
        }
        
        if let usrlStril = user.image , let url = URL(string: usrlStril){
            imageLoadDisposable = userImage.loadImage(url: url, indicator: nil)
        }
        
        
    }
}
