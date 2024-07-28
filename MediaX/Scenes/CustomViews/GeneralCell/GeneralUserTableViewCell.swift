//
//  GeneralUserTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 27/07/2024.
//

import UIKit
import RxSwift
import RxCocoa

class GeneralUserTableViewCell: UITableViewCell {
    static let identifier = "GeneralUserTableViewCell"

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var imageLoadDisposable:Disposable?
    var viewModel : SearchViewModel?
    var user:UserModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.layer.cornerRadius = followButton.frame.height / 2
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true

    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
    @IBAction func followButtonAction(_ sender: Any) {
        if let vm = viewModel, let id = user?.id{
            vm.followButtonRelay.accept("\(id)")
        }
    }
    
 
    
    
    func configureUser(user:UserModel){
        
        DispatchQueue.main.async{[weak self] in
            self?.userName.text = user.fullName ?? ""
            self?.checkFollowStatus(status: user.follow ?? false)
            
        }
        
        if let urlString = user.image , let url = URL(string: urlString){
            imageLoadDisposable = userImage.loadImage(url: url, indicator: nil)
        }
        
        
    }
    
    private func checkFollowStatus(status:Bool){
        if !status{
            followButton.backgroundColor = .main
            followButton.setTitle("Follow", for: .normal)

        }else{
            followButton.backgroundColor = .lightGray
            followButton.setTitle("UnFollow", for: .normal)
        }
        
    }


}
