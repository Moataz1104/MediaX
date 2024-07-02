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
    var logoutTimer: Timer?
    let sessionDuration: TimeInterval = 24 * 60 * 59
    
    
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
    }
    
    
    var accessToken :String?
    
    
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
        tab1Coordinator.delegate = self

        let tab2Coordinator = SearchCoordinator(navigationController: UINavigationController())
        
        let tab3Coordinator = AddPostCoordinator(navigationController: UINavigationController())
        
        let tab4Coordinator = NotificationCoordinator(navigationController: UINavigationController())
        let tab5Coordinator = ProfileCoordinator(navigationController: UINavigationController())
        
        childCoordinators.append(contentsOf: [tab1Coordinator as Coordinator, tab2Coordinator as Coordinator,tab3Coordinator as Coordinator, tab4Coordinator as Coordinator, tab5Coordinator as Coordinator])
        
        tab1Coordinator.start()
        tab2Coordinator.start()
        tab3Coordinator.start()
        tab4Coordinator.start()
        tab5Coordinator.start()
        
        tabBarController.viewControllers = [tab1Coordinator.navigationController,
                                            tab2Coordinator.navigationController,
                                            tab3Coordinator.navigationController,
                                            tab4Coordinator.navigationController,
                                            tab5Coordinator.navigationController]
        
        if let items = tabBarController.tabBar.items {
            items[0].image = UIImage(systemName: "house")
            items[0].selectedImage = UIImage(systemName: "house")
            items[0].title = "Home"
            
            items[1].image = UIImage(systemName: "magnifyingglass")
            items[1].selectedImage = UIImage(systemName: "magnifyingglass")
            items[1].title = "Search"
            
            items[2].image = UIImage(named: "PlusIcon")
            items[2].selectedImage = UIImage(named: "PlusIcon")
            items[2].title = "Post"

            
            items[3].image = UIImage(systemName: "bell")
            items[3].selectedImage = UIImage(systemName: "bell")
            items[3].title = "Notification"
            
            items[4].image = UIImage(systemName: "person")
            items[4].selectedImage = UIImage(systemName: "person")
            items[4].title = "Profile"
        }
        
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    private func hideTabBarDuringScrolling() {
        guard let tabBarController = navigationController.viewControllers.first as? UITabBarController else { return }
        UIView.animate(withDuration: 0.5) {
            tabBarController.tabBar.frame.origin.y = UIScreen.main.bounds.height 
        }
    }

    private func showTabBarDuringScrolling() {
        guard let tabBarController = navigationController.viewControllers.first as? UITabBarController else { return }
        UIView.animate(withDuration: 0.5) {
            tabBarController.tabBar.frame.origin.y = UIScreen.main.bounds.height - tabBarController.tabBar.frame.height
        }
    }


    
    
    //    MARK: - Handle the access token time
    
    func startLogoutTimer(with duration: TimeInterval) {
        print("duration \(duration)")
        
        invalidateLogoutTimer()
        DispatchQueue.main.async{[weak self] in
            
            self?.logoutTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                
                self?.logOut()
                
            }
        }
    }
    
    
    
    func logOut() {
        invalidateLogoutTimer()
        KeychainWrapper.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "loginTimestamp")

        DispatchQueue.main.async { [weak self] in
            self?.showAuth()
        }
    }

    
    
    private func startSession() {
        
        logoutTimer = Timer.scheduledTimer(withTimeInterval: sessionDuration, repeats: false){[weak self] _ in
            self?.logOut()
        }
    }
    
    
    private func invalidateLogoutTimer() {
        logoutTimer?.invalidate()
        logoutTimer = nil
    }
    
}

    



extension MainCoordinator: AuthCoordinatorDelegate {
    func didLoginSuccessfully() {
        DispatchQueue.main.async{[weak self] in
            self?.startSession()
            self?.showTabBar()
        }
    }
}

extension MainCoordinator: HomeViewDelegate {
    func didScrollDown() {
        hideTabBarDuringScrolling()
    }

    func didScrollUp() {
        showTabBarDuringScrolling()
    }
}
