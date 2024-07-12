//
//  ProfileView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import UIKit

class ProfileView: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true

        collectionView.delegate = self
        collectionView.dataSource = self
        registerCells()
        

    }


    func registerCells(){
        collectionView.register(UINib(nibName: UserInfoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: UserInfoCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: PostsGridCollectionViewCell.identfier, bundle: nil), forCellWithReuseIdentifier: PostsGridCollectionViewCell.identfier)
    }
}


extension ProfileView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserInfoCollectionViewCell.identifier, for: indexPath) as! UserInfoCollectionViewCell
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostsGridCollectionViewCell.identfier, for: indexPath) as! PostsGridCollectionViewCell
            return cell

        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            return CGSize(width: collectionView.bounds.width, height: 250)
        }else {
            let numberOfItemsPerRow: CGFloat = 3
            let width = collectionView.bounds.width / numberOfItemsPerRow
            return CGSize(width: width - 0.4, height: width - 1)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0{
            return UIEdgeInsets.zero
        }else{
            return UIEdgeInsets(top: 0.5, left: 0.2, bottom: 0.5, right: 0.2)
        }
    }

    

}
