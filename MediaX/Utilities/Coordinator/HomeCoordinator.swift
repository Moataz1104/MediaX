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
    
    
}
