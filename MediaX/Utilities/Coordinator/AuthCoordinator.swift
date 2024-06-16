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
    
    func showLogInScreen(){
        let vc = LogInView()
        navigationController.pushViewController(vc, animated: true)
    }
    
}
