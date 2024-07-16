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
    
    
}
