//
//  HomeCoordinator.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift



class HomeCoordinator:Coordinator{
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    weak var delegate: HomeViewDelegate?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let disposeBag = DisposeBag()
        let viewModel = PostsViewModel(disposeBag: disposeBag, coordinator: self)
        let storyViewModel = StoryViewModel(disposeBag: disposeBag, coordinator: self)
        let vc = HomeView(disposeBag: disposeBag, viewModel: viewModel,storyViewModel: storyViewModel)
        vc.delegate = delegate
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    func showCommentsScreen(post:PostModel){
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

        navigationController.present(vc, animated: true)
    }
    
    func showErrorInCommentScreen(_ error: Error) {
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

    func presentStoryScreen(indexPath:IndexPath){
        let vc = StoryView()
        vc.indexPath = indexPath
        vc.modalPresentationStyle = .fullScreen
        vc.heroModalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)

        DispatchQueue.main.async{[weak self] in
            self?.navigationController.present(vc, animated: true)
            
        }

    }
    
    func showOtherUsersScreen(id:String){
        let disposeBag = DisposeBag()
        let viewModel = ProfileViewModel(coordinator: self, disposeBag: disposeBag, isCurrentUser: false,userId:id)
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

}
