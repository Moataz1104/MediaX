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
    let user : UserModel?
    let isCurrentUser:Bool
    let isFromSearch:Bool

    var fetchedUser:UserModel?
    var posts:[PostModel]?
    var userId:String?
    
    var reloadcollectionViewClosure:(()->Void)?
    let isAnimatingPublisher = PublishRelay<Bool>()
    let followButtonRelay = PublishRelay<Void>()
    let getUserProfileRelay = PublishRelay<Void>()
    let errorPublisher = PublishRelay<Error>()
    let followerDetailsRelay = PublishRelay<String>()
    let followingDetailsRelay = PublishRelay<String>()
    
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    
    var getCurrentUserDisposable:Disposable?
    var getCurrentUserPostsDisposable:Disposable?
    
    
    init(coordinator: Coordinator, disposeBag: DisposeBag,
         user:UserModel? = nil,isCurrentUser:Bool,userId:String? = nil,isFromSearch:Bool = false) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        self.user = user
        self.isCurrentUser = isCurrentUser
        self.userId = userId
        self.isFromSearch = isFromSearch
        
        
        if let user = user{
            fetchedUser = user
            handleFollow()
            getOtherUserPosts()

        }else{
            if isCurrentUser{
                getCurrentUser()
                getCurrentUserPosts()
            }else{
                
                getOtherUserProfile()
                getOtherUserPosts()
                handleFollow()
            }
        }
        
        getFollowers()
        getFollowings()
    }
    
    
    
    
    func getCurrentUser(){
        guard let token = accessToken else{print("No TOKEN"); return}
        getCurrentUserDisposable?.dispose()
        getCurrentUserDisposable = APIUsers.shared.getCurrentUser(accessToken: token)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .catch({[weak self] error in
                self?.errorPublisher.accept(error)
                return .empty()
            })
            .subscribe {[weak self] user in
                self?.isAnimatingPublisher.accept(true)
                self?.fetchedUser = user
                self?.reloadcollectionViewClosure?()
                self?.isAnimatingPublisher.accept(false)
            }onError: {[weak self] error in
                self?.errorPublisher.accept(error)
                self?.isAnimatingPublisher.accept(false)

            }
    }
    
    func getCurrentUserPosts(){
        guard let token = accessToken else{print("No TOKEN"); return}
        getCurrentUserPostsDisposable?.dispose()
        getCurrentUserPostsDisposable =  APIUsers.shared.getCurrentUserPosts(accessToken: token)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .catch({[weak self] error in
                self?.errorPublisher.accept(error)
                return .empty()
            })
            .subscribe {[weak self] posts in
                self?.posts = posts
                self?.reloadcollectionViewClosure?()
            }onError: {[weak self] error in
                self?.errorPublisher.accept(error)
            }

    }

    
    func getOtherUserProfile() {
        guard let token = accessToken else {
            print("No token")
            return
        }
        guard let userId = userId else {
            print("No userId")
            return
        }
        
        let fetchUser: Observable<UserModel>
        
        if isFromSearch {
            fetchUser = APIUsers.shared.getUserFromSearch(by: userId, accessToken: token)
        } else {
            fetchUser = APIUsers.shared.getOtherUserProfile(by: userId, accessToken: token)
        }
        
        getUserProfileRelay
            .flatMapLatest { _ -> Observable<UserModel> in
                return fetchUser
                    .observe(on: MainScheduler.instance)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .catch { [weak self] error in
                        self?.errorPublisher.accept(error)
                        return Observable.empty()
                    }
            }
            .subscribe { [weak self] user in
                self?.fetchedUser = user
                self?.reloadcollectionViewClosure?()
            } onError: { [weak self] error in
                self?.errorPublisher.accept(error)
            }
            .disposed(by: disposeBag)
    }

    func getOtherUserPosts(){
        guard let token = accessToken else{print("No tokeeeen"); return}
        guard let userId = userId else{return}

        APIUsers.shared.getOtherUserPosts(by: userId, accessToken: token)
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .catch({[weak self] error in
                self?.errorPublisher.accept(error)
                return .empty()
            })
            .subscribe {[weak self] posts in
                self?.posts = posts
                self?.reloadcollectionViewClosure?()
            }onError: {[weak self] error in
                self?.errorPublisher.accept(error)
            }
            .disposed(by: disposeBag)
    }
    
    func handleFollow(){
        guard let token = accessToken else{print("No tokeeeen"); return}
        guard let userId = userId else{return}

        followButtonRelay
            .flatMapLatest { _ -> Observable<Void> in
                APIUsers.shared.followUser(accessToken: token, userId: userId)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {[weak self]error in
                        self?.errorPublisher.accept(error)
                        return Observable.empty()
                    }
            }
            .retry()
            .subscribe {[weak self] _ in
                self?.getUserProfileRelay.accept(())
                self?.reloadcollectionViewClosure?()
            }onError: {[weak self] error in
                
                self?.errorPublisher.accept(error)
            }
            .disposed(by: disposeBag)
    }
    
    func getFollowers(){
        guard let token = accessToken else{print("No tokeeeen"); return}
        
        followerDetailsRelay
            .flatMapLatest { id -> Observable<[UserModel]> in
                return APIUsers.shared.getFollowersDetails(accessToken: token, id: id)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] followers in
                self?.pushFollowersScreen(followers: followers)
            }
            .disposed(by: disposeBag)
    }
    
    func getFollowings(){
        guard let token = accessToken else{print("No tokeeeen"); return}
        
        followingDetailsRelay
            .flatMapLatest { id -> Observable<[UserModel]> in
                
                return APIUsers.shared.getFolloweingsDetails(accessToken: token, id: id)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] followings in
                self?.pushFollowingsScreen(followings: followings)
            }
            .disposed(by: disposeBag)
    }

    
    
//    MARK: - Navigation
    
    func pushPostDetailScreen(indexPath:IndexPath){
        if let posts = posts , let coordinator = coordinator as? ProfileCoordinator{
            coordinator.pushPostDetailScreen(posts: posts, indexPath: indexPath)
        }else if let posts = posts ,  let coordinator = coordinator as? HomeCoordinator{
            coordinator.pushPostDetailScreen(posts: posts, indexPath: indexPath) 
        }else if let posts = posts , let coordinator = coordinator as? SearchCoordinator{
            coordinator.pushPostDetailScreen(posts: posts, indexPath: indexPath)

        }
    }
    
    func pushSettingScreen(){
        if let user = fetchedUser , let coordinator = coordinator as? ProfileCoordinator{
            coordinator.pushSettingScreen(user:user)
        }
    }
    
    
    private func pushFollowersScreen(followers:[UserModel]){
        if let coordinator = coordinator as? ProfileCoordinator{
            coordinator.pushFollowersScreen(followers: followers)
        }else if let coordinator = coordinator as? HomeCoordinator{
            coordinator.pushFollowersScreen(followers: followers)

        }else if let coordinator = coordinator as? SearchCoordinator{
            coordinator.pushFollowersScreen(followers: followers)

        }

    }
    private func pushFollowingsScreen(followings:[UserModel]){
        if let coordinator = coordinator as? ProfileCoordinator{
            coordinator.pushFollowingScreen(followings: followings)
        }else if let coordinator = coordinator as? HomeCoordinator{
            coordinator.pushFollowingScreen(followings: followings)

        }else if let coordinator = coordinator as? SearchCoordinator{
            coordinator.pushFollowingScreen(followings: followings)
        }

    }

}
