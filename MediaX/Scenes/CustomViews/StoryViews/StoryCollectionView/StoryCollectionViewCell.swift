//
//  StoryCollectionViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 29/06/2024.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "StoryCollectionViewCell"
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()

    }
    
    private func configUi(){
        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true

    }
}
