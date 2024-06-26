//
//  StoriesTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 29/06/2024.
//

import UIKit

class StoriesTableViewCell: UITableViewCell {
    static let identifier = "StoriesTableViewCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        registerAndSetDelegates()
        collectionView.backgroundColor = .backGroundMain
        collectionView.bounces = false
    }
        
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        
        let collectionViewHeight: CGFloat = 120
        let itemHeight: CGFloat = collectionViewHeight - layout.minimumLineSpacing * 2
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)

        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: MyStoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MyStoryCollectionViewCell.identifier)

        collectionView.register(UINib(nibName: StoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }


    
    private func registerAndSetDelegates() {
        collectionView.register(UINib(nibName: StoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension StoriesTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyStoryCollectionViewCell.identifier, for: indexPath) as! MyStoryCollectionViewCell
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.identifier, for: indexPath) as! StoryCollectionViewCell
            return cell
            
        }
       
    }
}
