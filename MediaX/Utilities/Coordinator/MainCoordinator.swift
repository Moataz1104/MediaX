//
//  MainCoordinator.swift
//  MediaX
//
//  Created by Moataz Mohamed on 17/06/2024.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class MainCoordinator : Coordinator{
    var childCoordinators = [Coordinator]()
    var navigationController : UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    let accessToken :String? = KeychainWrapper.standard.string(forKey: "token")
    
    
    
    func start() {
        print(accessToken ?? "No token")
        if let _ = KeychainWrapper.standard.string(forKey: "token") {
            print("Done")
        } else {
            showAuth()
        }
    }
    
    func showAuth(){
        let childCoordinator = AuthCoordinator(navigationController: navigationController)
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
    
    
}
