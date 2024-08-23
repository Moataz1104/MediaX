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
    
    var disposeBag = DisposeBag()
    weak var viewModel:SearchViewModel?
    var user:UserModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
        disposeBag = DisposeBag()
    }
    
    @IBAction func xButtonAction(_ sender: Any) {
        if let vm = viewModel,let id = user?.id{
            vm.deleteFromRecentRelay.accept("\(id)")
        }
    }
 
    
    
    func configureUser(user:UserModel){
        
        DispatchQueue.main.async{[weak self] in
            self?.userName.text = user.fullName ?? ""
        }
        
        if let urlString = user.image , let url = URL(string: urlString){
            userImage.loadImage(url: url, indicator: nil)
                .disposed(by: disposeBag)
        }
        
        
    }
}
