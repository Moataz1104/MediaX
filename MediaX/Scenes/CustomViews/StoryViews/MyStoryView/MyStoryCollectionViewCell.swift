//
//  MyStoryCollectionViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 29/06/2024.
//

import UIKit

class MyStoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "MyStoryCollectionViewCell"
    
    @IBOutlet weak var myImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        configUi()

    }
    
    private func configUi(){
        myImage.layer.cornerRadius = myImage.bounds.width / 2
        myImage.clipsToBounds = true
        

    }
    
}
