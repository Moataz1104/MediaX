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
    @IBOutlet weak var timeLabel: UILabel!

    weak var searchViewModel : SearchViewModel?
    weak var generalUsersViewModel : GeneralUsersViewModel?
    var user:UserModel?
    var isFollow:Bool?
    
    let followRelay = PublishRelay<Bool>()
    var disposeBag = DisposeBag()


    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.layer.cornerRadius = followButton.frame.height / 2
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
        timeLabel.isHidden = true
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
        disposeBag = DisposeBag()

    }
    
    
    @IBAction func followButtonAction(_ sender: Any) {
        if let vm = searchViewModel, let id = user?.id{
            vm.followButtonRelay.accept("\(id)")

        }else if let vm = generalUsersViewModel , let id = user?.id{
            vm.followButtonRelay.accept("\(id)")
        }
        
        if var isFollow = isFollow{
            isFollow.toggle()
            followRelay.accept(isFollow)
        }

    }
    
 
    
    
    func configureUser(user: UserModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.userName.text = user.fullName ?? user.username ?? ""
            
            if let timeAgo = user.timeAgo {
                self.timeLabel.isHidden = false
                self.timeLabel.text = timeAgo
            }
            self.checkFollowStatus(followStatus: user.follow)
            self.isFollow = user.follow
        }
        followRelay
            .observe(on: MainScheduler.instance)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] isFollow in
                self?.checkFollowStatus(followStatus: isFollow)
            })
            .disposed(by: disposeBag)

        
        if let urlString = user.image ?? user.userImage, let url = URL(string: urlString) {
             userImage.loadImage(url: url, indicator: nil)
                .disposed(by: disposeBag)
        }
    }
    
    private func checkFollowStatus(followStatus:Bool?){
        
        
        if let followStatus = followStatus{
            if !followStatus{
                followButton.backgroundColor = .main
                followButton.setTitle("Follow", for: .normal)
            }else{
                followButton.backgroundColor = .lightGray
                followButton.setTitle("UnFollow", for: .normal)
            }
        }else{
            followButton.isHidden = true
        }
    }


}
