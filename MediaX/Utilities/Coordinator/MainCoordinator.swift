//
//  MainCoordinator.swift
//  MediaX
//
//  Created by Moataz Mohamed on 17/06/2024.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import RxSwift
import RxCocoa


class MainCoordinator : Coordinator{
    var childCoordinators = [Coordinator]()
    var navigationController : UINavigationController
    
    
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
    }
    
    
    let accessToken :String? = KeychainWrapper.standard.string(forKey: "token")
    
    
    func start() {
        if accessToken != nil {
            showTabBar()
        } else {
            showAuth()
        }
    }
    
    func showAuth(){
        let childCoordinator = AuthCoordinator(navigationController: navigationController)
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
    
    func showTabBar() {
        DispatchQueue.main.async { [weak self] in
            
            let tabBarController = UITabBarController()
            
            
            tabBarController.tabBar.barStyle = .black
            tabBarController.tabBar.backgroundColor = .main
            
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .main
            
            
            appearance.stackedLayoutAppearance.normal.iconColor = .white
            
            appearance.stackedLayoutAppearance.selected.iconColor = .white
            
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .semibold)]
            
                        
            tabBarController.tabBar.standardAppearance = appearance
            
            let tab1Coordinator = HomeCoordinator(navigationController: UINavigationController())
            let tab2Coordinator = SearchCoordinator(navigationController: UINavigationController())
            let tab3Coordinator = NotificationCoordinator(navigationController: UINavigationController())
            let tab4Coordinator = ProfileCoordinator(navigationController: UINavigationController())
            
            self?.childCoordinators.append(contentsOf: [tab1Coordinator as Coordinator, tab2Coordinator as Coordinator, tab3Coordinator as Coordinator, tab4Coordinator as Coordinator])
            
            tab1Coordinator.start()
            tab2Coordinator.start()
            tab3Coordinator.start()
            tab4Coordinator.start()
            
            tabBarController.viewControllers = [tab1Coordinator.navigationController,
                                                tab2Coordinator.navigationController,
                                                tab3Coordinator.navigationController,
                                                tab4Coordinator.navigationController]
            
            if let items = tabBarController.tabBar.items {
                items[0].image = UIImage(systemName: "house")
                items[0].selectedImage = UIImage(systemName: "house")
                items[0].title = "Home"
                
                
                items[1].image = UIImage(systemName: "magnifyingglass")
                items[1].selectedImage = UIImage(systemName: "magnifyingglass")
                items[1].title = "Search"
                
                items[2].image = UIImage(systemName: "bell")
                items[2].selectedImage = UIImage(systemName: "bell")
                items[2].title = "Notification"
                
                items[3].image = UIImage(systemName: "person")
                items[3].selectedImage = UIImage(systemName: "person")
                items[3].title = "Profile"
            }
            
            self?.navigationController.setViewControllers([tabBarController], animated: true)
        }
    }
}




extension MainCoordinator: AuthCoordinatorDelegate {
    func didLoginSuccessfully() {
        showTabBar()
    }
}
