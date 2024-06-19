//
//  AuthCoordinator.swift
//  MediaX
//
//  Created by Moataz Mohamed on 17/06/2024.
//

import Foundation
import UIKit


class AuthCoordinator : Coordinator {
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLogInScreen()
    }
    
    func popVC(){
        DispatchQueue.main.async {[weak self] in
            self?.navigationController.popViewController(animated: true)
        }
    }
    
    
    func showLogInScreen(){
        let viewModel = LogInViewModel(coordinator: self)
        let vc = LogInView(viewModel: viewModel)
        
        navigationController.pushViewController(vc, animated: true)
    }

    
    func showSignUpScreen(){
        let viewModel = RegisterViewModel(coordinator: self)
        let vc = RegisterView(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
