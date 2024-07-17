//
//  ProfileViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 12/07/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper

class ProfileViewModel{
    var coordinator:Coordinator?
    let disposeBag:DisposeBag
    
    var user:UserModel?
    var posts:[PostModel]?
    
    var reloadcollectionViewClosure:(()->Void)?
    let isAnimatingPublisher = PublishRelay<Bool>()
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    init(coordinator: Coordinator, disposeBag: DisposeBag) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        
        getCurrentUser()
        getCurrentUserPosts()
        }
    
    
    
    
    func getCurrentUser(){
        guard let token = accessToken else{print("No TOKEN"); return}
        
        APIUsers.shared.getCurrentUser(accessToken: token)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] user in
                self?.isAnimatingPublisher.accept(true)
                self?.user = user
                self?.reloadcollectionViewClosure?()
                self?.isAnimatingPublisher.accept(false)
            }onError: {[weak self] error in
                print(error.localizedDescription)
                self?.isAnimatingPublisher.accept(false)

            }
            .disposed(by: disposeBag)
    }
    
    func getCurrentUserPosts(){
        guard let token = accessToken else{print("No TOKEN"); return}
        APIUsers.shared.getCurrentUserPosts(accessToken: token)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] posts in
                self?.posts = posts
                self?.reloadcollectionViewClosure?()
            }onError: { error in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)

    }

    
//    MARK: - Navigation
    
    func pushPostDetailScreen(indexPath:IndexPath){
        if let posts = posts , let coordinator = coordinator as? ProfileCoordinator{
            coordinator.pushPostDetailScreen(posts: posts, indexPath: indexPath)
        }
    }
    
    func pushSettingScreen(){
        if let user = user , let coordinator = coordinator as? ProfileCoordinator{
            coordinator.pushSettingScreen(user:user)
        }
    }
}
