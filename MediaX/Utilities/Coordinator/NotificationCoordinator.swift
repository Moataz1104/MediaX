//
//  NotificationCoordinator.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class NotificationCoordinator:Coordinator{
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let disposeBag = DisposeBag()
        let viewModel = NotificationViewModel(disposeBag: disposeBag, coordinator: self)
        let vc = NotificationView(disposeBag: disposeBag, viewModel: viewModel)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    func pushProfileScreen(user:UserModel){
        let disposeBag = DisposeBag()
        let viewModel = ProfileViewModel(coordinator: self, disposeBag: disposeBag,user:user, isCurrentUser: false )
        let vc = ProfileView(viewModel: viewModel, disposeBag: disposeBag, isCurrentUser: false)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushSinglePostScreen(post:PostModel){
        let disposeBag = DisposeBag()
        let postVM = PostsViewModel(disposeBag: disposeBag, coordinator: self)
        
        let vc = SinglePostView(postVM: postVM, post: post)
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
            }else{
                self?.navigationController.present(vc, animated: true)
            }
        }
    }

    func showOtherUsersScreen(id:String){
        let disposeBag = DisposeBag()
        let viewModel = ProfileViewModel(coordinator: self, disposeBag: disposeBag, isCurrentUser: false,userId:id)
        let vc = ProfileView(viewModel: viewModel, disposeBag: disposeBag, isCurrentUser: false)
        
        
        DispatchQueue.main.async { [weak self] in
            if let topVC = self?.navigationController.presentedViewController {
                topVC.dismiss(animated: true)
                topVC.dismiss(animated: false)
                self?.navigationController.pushViewController(vc, animated: true)

            }else{
                self?.navigationController.pushViewController(vc, animated: true)
            }
        }

    }

    
    func PushGeneralScreen(users:[UserModel],screenTitle:String,isLikeScreen:Bool = false){
        let disposeBag = DisposeBag()
        let viewModel = GeneralUsersViewModel(disposeBag: disposeBag, coordinator: self, users: users)
        let vc = GeneralUsersView(viewModel: viewModel, title: screenTitle,isLikeScreen : isLikeScreen)
        
        
        DispatchQueue.main.async { [weak self] in
            if let topVC = self?.navigationController.presentedViewController {
                topVC.dismiss(animated: true)
                topVC.dismiss(animated: false)
                self?.navigationController.pushViewController(vc, animated: true)

            }else{
                self?.navigationController.pushViewController(vc, animated: true)
            }
        }

    }


}
