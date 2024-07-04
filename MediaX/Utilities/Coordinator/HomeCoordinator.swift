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
        let viewModel = HomeViewModel(disposeBag: disposeBag, coordinator: self)
        let vc = HomeView(disposeBag: disposeBag, viewModel: viewModel)
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
    
        
    
}
