//
//  StoryCollectionViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 29/06/2024.
//

import UIKit
import Hero
class StoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "StoryCollectionViewCell"
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var indexPath:IndexPath?

    var viewModel:PostsViewModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()

    }
    
    private func configUi(){
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        
        backGroundView.layer.cornerRadius = backGroundView.bounds.width / 2
        backGroundView.clipsToBounds = true
        backGroundView.layer.borderWidth = 2
        backGroundView.layer.borderColor = UIColor.main.cgColor

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        userImage.addGestureRecognizer(tapGesture)
        userImage.isUserInteractionEnabled = true
        
        if let indexPath = indexPath{
            userImage.heroID = "\(indexPath.row)"
        }
    }
    
    @objc func handleImageTap(){
        if let indexPath = indexPath{
            viewModel?.presentStoryScreen(indexPath:indexPath)
        }
    }
}
