//
//  SceneDelegate.swift
//  MediaX
//
//  Created by Moataz Mohamed on 16/06/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var coordinator : MainCoordinator?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let navigationController = UINavigationController()
        coordinator = MainCoordinator(navigationController: navigationController)
        
        
        
        
        if let loginTimestamp = UserDefaults.standard.object(forKey: "loginTimestamp") as? Date {
            
            
            let sessionDuration: TimeInterval = 24 * 60 * 59
            let timeElapsed = Date().timeIntervalSince(loginTimestamp)
            
            if timeElapsed > sessionDuration {
                
                coordinator?.logOut()
            } else {
                let remainingTime = sessionDuration - timeElapsed
                
                coordinator?.startLogoutTimer(with: remainingTime)
                
                
                coordinator?.start()
            }
        } else {
            coordinator?.start()
        }
        
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

