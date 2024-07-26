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
    let isCurrentUser:Bool

    var user:UserModel?
    var posts:[PostModel]?
    var userId:String?
    
    var reloadcollectionViewClosure:(()->Void)?
    let isAnimatingPublisher = PublishRelay<Bool>()
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    
    var getCurrentUserDisposable:Disposable?
    var getCurrentUserPostsDisposable:Disposable?
    
    
    init(coordinator: Coordinator, disposeBag: DisposeBag,isCurrentUser:Bool,userId:String? = nil) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        self.isCurrentUser = isCurrentUser
        self.userId = userId
        
        if isCurrentUser{
            getCurrentUser()
            getCurrentUserPosts()
        }else{
            getOtherUserProfile()
            getOtherUserPosts()
        }
    }
    
    
    
    
    func getCurrentUser(){
        guard let token = accessToken else{print("No TOKEN"); return}
        getCurrentUserDisposable?.dispose()
        getCurrentUserDisposable = APIUsers.shared.getCurrentUser(accessToken: token)
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
    }
    
    func getCurrentUserPosts(){
        guard let token = accessToken else{print("No TOKEN"); return}
        getCurrentUserPostsDisposable?.dispose()
        getCurrentUserPostsDisposable =  APIUsers.shared.getCurrentUserPosts(accessToken: token)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] posts in
                self?.posts = posts
                self?.reloadcollectionViewClosure?()
            }onError: { error in
                print(error.localizedDescription)
            }

    }

    
    func getOtherUserProfile(){
        guard let token = accessToken else{print("No tokeeeen"); return}
        guard let userId = userId else{return}
        
        APIUsers.shared.getOtherUserProfile(by: userId, accessToken: token)
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe {[weak self] user in
                self?.user = user
                self?.reloadcollectionViewClosure?()
            }onError: { error in
                print(error)
            }
            .disposed(by: disposeBag)
    }
    
    func getOtherUserPosts(){
        guard let token = accessToken else{print("No tokeeeen"); return}
        guard let userId = userId else{return}

        APIUsers.shared.getOtherUserPosts(by: userId, accessToken: token)
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
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
        }else if let posts = posts ,  let coordinator = coordinator as? HomeCoordinator{
            coordinator.pushPostDetailScreen(posts: posts, indexPath: indexPath) 
        }
    }
    
    func pushSettingScreen(){
        if let user = user , let coordinator = coordinator as? ProfileCoordinator{
            coordinator.pushSettingScreen(user:user)
        }
    }

}
