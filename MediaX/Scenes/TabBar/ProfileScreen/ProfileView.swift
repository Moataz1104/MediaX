//
//  ProfileView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Hero
class ProfileView: UIViewController {

//    MARK: - Attributes
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var settingButtonOutlet: UIButton!
    

    
    let viewModel:ProfileViewModel
    let disposeBag = DisposeBag()
    let isCurrentUser:Bool
    var refreshControl = UIRefreshControl()
    

//    MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        indicator.isHidden = true
        indicator.stopAnimating()
        self.hero.isEnabled = true
        
        refreshControl.tintColor = UIColor.main
        subscribeToErrorPublisher()
        setUpCollectionView()
        registerCells()
        reloadCollectioView()
        refreshCollectionView()
        subscribeToIndicatorPublisher()
        
        if isCurrentUser{
            settingButtonOutlet.isHidden = false
        }else{
            settingButtonOutlet.isHidden = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCurrentUser{
            viewModel.getCurrentProfileRelay.accept(())
            viewModel.getCurrentPostsRelay.accept(())

        }else{
            viewModel.getUserProfileRelay.accept(())
            viewModel.getUserPostsRelay.accept(())

        }
    }
    
    init(viewModel:ProfileViewModel,isCurrentUser:Bool){
        self.viewModel = viewModel
        self.isCurrentUser = isCurrentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Actions
    
    @IBAction func settingButtonAction(_ sender: Any) {
        viewModel.pushSettingScreen()
    }
    

//  MARK: - Subscribers
    private func subscribeToIndicatorPublisher(){
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
    
        
    private func subscribeToErrorPublisher() {
        viewModel.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let error = event.element else {
                    print("Error element is nil")
                    return
                }
                let vc = ErrorsAlertView()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                
                if let networkingError = error as? NetworkingErrors {
                    DispatchQueue.main.async {
                        vc.errorTitle?.text = networkingError.title
                        vc.errorMessage?.text = networkingError.localizedDescription
                    }
                } else {
                    DispatchQueue.main.async {
                        vc.errorMessage?.text = error.localizedDescription
                    }
                }
                self?.present(vc, animated: true, completion: nil)

            }
            .disposed(by: disposeBag)
    }

    
    //    MARK: - Privates
    private func setUpCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
    }
    
    private func registerCells(){
        collectionView.register(UINib(nibName: UserInfoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: UserInfoCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: PostsGridCollectionViewCell.identfier, bundle: nil), forCellWithReuseIdentifier: PostsGridCollectionViewCell.identfier)
    }
    private func reloadCollectioView(){
        DispatchQueue.main.async {[weak self] in
            self?.viewModel.reloadcollectionViewClosure = {
                self?.collectionView.reloadData()
            }
        }
        
    }
    private func refreshCollectionView(){
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }

    @objc func refreshData() {
        DispatchQueue.main.async{[weak self] in
            self?.refreshControl.beginRefreshing()
            if self?.isCurrentUser == true{
                self?.viewModel.getCurrentProfileRelay.accept(())
                self?.viewModel.getCurrentPostsRelay.accept(())
            }else{
                self?.viewModel.getUserProfileRelay.accept(())
                self?.viewModel.getUserPostsRelay.accept(())

            }
            self?.refreshControl.endRefreshing()
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
            return viewModel.posts?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserInfoCollectionViewCell.identifier, for: indexPath) as! UserInfoCollectionViewCell
            cell.viewModel = viewModel
            if let user = viewModel.fetchedUser{
                if isCurrentUser{
                    cell.configureCell(with: user,isFollowButtonHidden:true)
                    cell.user = user
                }else{
                    cell.configureCell(with: user,isFollowButtonHidden:false)
                    cell.user = user
                }
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostsGridCollectionViewCell.identfier, for: indexPath) as! PostsGridCollectionViewCell
            cell.viewModel = viewModel
            if let posts = viewModel.posts{
                cell.configureCell(with: posts[indexPath.row])
                cell.post = posts[indexPath.row]
                cell.indexPath = indexPath
            }

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
