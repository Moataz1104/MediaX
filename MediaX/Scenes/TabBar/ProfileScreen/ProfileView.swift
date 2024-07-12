//
//  ProfileView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileView: UIViewController {

//    MARK: - Attributes
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    let viewModel:ProfileViewModel
    let disposeBag:DisposeBag
    
//    MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setUpCollectionView()
        registerCells()
        reloadCollectioView()
        indicator.isHidden = true
        indicator.stopAnimating()

        
        viewModel.isAnimatingPublisher
            .observe(on: MainScheduler.instance)
            .subscribe{[weak self] isAnimating in
                if isAnimating{
                    self?.indicator.isHidden = false
                    self?.indicator.startAnimating()

                }else{
                    self?.indicator.isHidden = true
                    self?.indicator.stopAnimating()

                }
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getCurrentUser()
    }
    
    init(viewModel:ProfileViewModel,disposeBag:DisposeBag){
        self.viewModel = viewModel
        self.disposeBag = disposeBag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


//    MARK: - Privates
    private func registerCells(){
        collectionView.register(UINib(nibName: UserInfoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: UserInfoCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: PostsGridCollectionViewCell.identfier, bundle: nil), forCellWithReuseIdentifier: PostsGridCollectionViewCell.identfier)
    }
    private func setUpCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

    }
    private func reloadCollectioView(){
        viewModel.reloadcollectionViewClosure = {[weak self] in
            self?.collectionView.reloadData()
        }
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
            cell.viewModel = viewModel
            if let user = viewModel.user{
                cell.configureCell(with: user)
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostsGridCollectionViewCell.identfier, for: indexPath) as! PostsGridCollectionViewCell
            return cell

        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            return CGSize(width: collectionView.bounds.width, height: 180)
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
