//
//  ProfileCoordinator.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Hero

class ProfileCoordinator:Coordinator{
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let disposeBag = DisposeBag()
        let viewModel = ProfileViewModel(coordinator: self, disposeBag: disposeBag, isCurrentUser: true)
        let vc = ProfileView(viewModel: viewModel,disposeBag:disposeBag, isCurrentUser: true)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
 
    func pushPostDetailScreen(posts:[PostModel],indexPath:IndexPath){
        let disposeBag = DisposeBag()
        let postVM = PostsViewModel(disposeBag: disposeBag, coordinator: self)

        let vc = PostDetailView(posts: posts,postVM: postVM, indexPath: indexPath)
        vc.modalPresentationStyle = .fullScreen
        vc.hero.modalAnimationType = .zoom
        DispatchQueue.main.async{[weak self] in
            self?.navigationController.present(vc, animated: true)
            
        }
    }
    
    func showCommentsScreen(post:PostModel) {
        let disposeBag = DisposeBag()
        let viewModel = CommentsViewModel(disposeBag: disposeBag, coordinator: self, post: post)
        let vc = CommentsView(viewModel: viewModel, disposeBag: disposeBag,post:post)
        
        vc.modalPresentationStyle = .pageSheet
        let multiplier = 0.65
        let fraction = UISheetPresentationController.Detent.custom { context in
            UIScreen.main.bounds.height * multiplier
            
        }

        vc.sheetPresentationController?.detents = [
            fraction,
            .large(),
            
        ]
        DispatchQueue.main.async { [weak self] in
            if let topVC = self?.navigationController.presentedViewController {
                topVC.present(vc, animated: true)
            }
        }
    }
    
    func pushSettingScreen(user:UserModel){
        let disposeBag = DisposeBag()
        let viewModel = SettingViewModel(disposeBag: disposeBag, coordinator: self, user: user)
        let vc = SettingView(disposeBag: disposeBag, viewModel: viewModel , user:user)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        DispatchQueue.main.async{[weak self] in
            self?.navigationController.present(vc, animated: true)
        }
        
    }
    
    func showErrorInSettingScreen(_ error: Error) {
        guard let topVC = navigationController.presentedViewController else {
            print("No presented view controller to present over.")
            return
        }

        let vc = ErrorsAlertView(nibName: "ErrorsAlertView", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        if let networkingError = error as? NetworkingErrors {
            vc.loadViewIfNeeded()
            vc.errorTitle?.text = networkingError.title
            vc.errorMessage?.text = networkingError.localizedDescription
        } else {
            vc.loadViewIfNeeded()
            vc.errorMessage?.text = error.localizedDescription
        }

        topVC.present(vc, animated: true)
    }
    
    
    func pushFollowersScreen(followers:[UserModel]){
        let disposeBag = DisposeBag()
        let viewModel = GeneralUsersViewModel(disposeBag: disposeBag, coordinator: self, users: followers)
        let vc = GeneralUsersView(viewModel: viewModel, title: "Followers")
        
        navigationController.pushViewController(vc, animated: true)
    }

    func pushFollowingScreen(followings:[UserModel]){
        let disposeBag = DisposeBag()
        let viewModel = GeneralUsersViewModel(disposeBag: disposeBag, coordinator: self, users: followings)
        let vc = GeneralUsersView(viewModel: viewModel, title: "Followings")
        
        navigationController.pushViewController(vc, animated: true)
    }

}
