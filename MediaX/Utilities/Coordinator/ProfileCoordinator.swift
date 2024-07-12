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

class ProfileCoordinator:Coordinator{
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let disposeBag = DisposeBag()
        let viewModel = ProfileViewModel(coordinator: self, disposeBag: disposeBag)
        let vc = ProfileView(viewModel: viewModel,disposeBag:disposeBag)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    
}
