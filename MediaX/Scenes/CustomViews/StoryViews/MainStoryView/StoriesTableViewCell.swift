//
//  StoriesTableViewCell.swift
//  MediaX
//
//  Created by Moataz Mohamed on 29/06/2024.
//

import UIKit

class StoriesTableViewCell: UITableViewCell {
    static let identifier = "StoriesTableViewCell"
    
    
//    MARK: - Attributes
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel : StoryViewModel?
    
//    MARK: - Cell life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        registerAndSetDelegates()
        collectionView.backgroundColor = .backGroundMain
        collectionView.bounces = true
        

    }
        
//    MARK: Privates
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5

        let collectionViewHeight: CGFloat = 120
        let itemHeight: CGFloat = collectionViewHeight - layout.minimumLineSpacing * 2
        layout.itemSize = CGSize(width: itemHeight - 25, height: itemHeight - 25)

        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(UINib(nibName: StoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }


    
    private func registerAndSetDelegates() {
        collectionView.register(UINib(nibName: StoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func reloadData(){
        collectionView.reloadData()
    }
}

extension StoriesTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.stories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.identifier, for: indexPath) as! StoryCollectionViewCell
        cell.indexPath = indexPath
        cell.viewModel = viewModel
        if let stories = viewModel?.stories{
            cell.story = stories[indexPath.row]
            cell.configureCell(with:stories[indexPath.row] )
        }
        return cell
    }
}
