//
//  StoryCollectionViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 29/06/2024.
//

import UIKit
import Hero
import RxSwift
import RxCocoa

protocol StoryCellDelegate: AnyObject {
    func didTapSelectImage()
}


class StoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "StoryCollectionViewCell"
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var indexPath:IndexPath?
    weak var viewModel:StoryViewModel?
    var story:StoryModel?
    weak var delegate: StoryCellDelegate?

    var disposeBag = DisposeBag()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()
        indicator.isHidden = true
        indicator.stopAnimating()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        indicator.isHidden = true
        indicator.stopAnimating()

    }
    
    private func configUi(){
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        backGroundView.layer.cornerRadius = backGroundView.bounds.width / 2
        backGroundView.clipsToBounds = true
        backGroundView.layer.borderWidth = 2

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        userImage.addGestureRecognizer(tapGesture)
        userImage.isUserInteractionEnabled = true
        
        if let indexPath = indexPath{
            userImage.heroID = "\(indexPath.row)"
        }
    }
    
    @objc func handleImageTap(){
        indicator.startAnimating()
        indicator.isHidden = false
        if let indexPath = indexPath , let story = story, let id = story.storyId{
            viewModel?.getStoryDetailsRelay.accept((indexPath,"\(id)"))
        }else{
            delegate?.didTapSelectImage()
        }
    }
    
    
    
    
    func configureCell(with story : StoryModel){
        
        DispatchQueue.main.async{[weak self] in
            self?.userName.text = story.username ?? ""
            
            if story.watched ?? false{
                self?.backGroundView.layer.borderColor = UIColor.clear.cgColor
            }else{
                self?.backGroundView.layer.borderColor = UIColor.main.cgColor
            }
        }
        if let userImageStr = story.userImage , let url = URL(string: userImageStr){
            userImage.loadImage(url: url)
        }

    }
}


