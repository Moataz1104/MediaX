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
        let commentVM = CommentsViewModel(disposeBag: disposeBag, coordinator: self, post: post)
        
        let vc = SinglePostView(postVM: postVM, commentVM: commentVM, post: post)
        navigationController.pushViewController(vc, animated: true)
    }
}
