//
//  SearchCoordinator.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SearchCoordinator:Coordinator{
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let disposeBag = DisposeBag()
        let viewModel = SearchViewModel(coordinator: self, disposeBag: disposeBag)
        let vc = SearchView(viewModel: viewModel, disposeBag: disposeBag)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    func pushProfileScreen(id:String){
        let disposeBag = DisposeBag()
        let viewModel = ProfileViewModel(coordinator: self, disposeBag: disposeBag, isCurrentUser: false, userId: id,isFromSearch: true)
        let vc = ProfileView(viewModel: viewModel, disposeBag: disposeBag, isCurrentUser: false)
        
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

}
