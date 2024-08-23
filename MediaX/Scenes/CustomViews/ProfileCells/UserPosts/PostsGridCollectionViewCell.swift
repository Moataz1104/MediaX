//
//  PostsGridCollectionViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 12/07/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Hero



class PostsGridCollectionViewCell: UICollectionViewCell {
    static let identfier = "PostsGridCollectionViewCell"

//    MARK: - Attributes
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    var disposeBag = DisposeBag()
    weak var viewModel:ProfileViewModel?
    var post:PostModel?
    var indexPath:IndexPath?
//    MARK: - Cell life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        imageGestureSetUp()
        indicator.isHidden = true
        indicator.stopAnimating()
        if let indexPath = indexPath{
            postImage.heroID = "\(indexPath.row)"
        }

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        postImage.image = nil
    }

//    MARK: - Actions
    
    func imageGestureSetUp(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapAction))
        postImage.addGestureRecognizer(tapGesture)
        postImage.isUserInteractionEnabled = true

    }
    @objc func imageTapAction(){
        if let indexPath = indexPath{
            viewModel?.pushPostDetailScreen(indexPath: indexPath)
        }
    }

    
    
//    MARK: - Configuration
    func configureCell(with post: PostModel){
        if let imageUrlString = post.image,
           let url = URL(string: imageUrlString){
            postImage.loadImage(url: url ,indicator:indicator)
                .disposed(by: disposeBag)
        }

    }
    

}
