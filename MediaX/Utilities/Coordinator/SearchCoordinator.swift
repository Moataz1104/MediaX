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

    
}
