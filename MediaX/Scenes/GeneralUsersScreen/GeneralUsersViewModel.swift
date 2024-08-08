//
//  GeneralUsersViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 06/08/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper


class GeneralUsersViewModel{
    let disposeBag:DisposeBag
    let coordinator:Coordinator
    var users:[UserModel]
    let followButtonRelay = PublishRelay<String>()
    let getUserRelay = PublishRelay<String>()
    let errorPublisher = PublishRelay<Error>()

    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    var reloadTableViewClosure:(()->Void)?

    init(disposeBag: DisposeBag, coordinator: Coordinator,users:[UserModel]) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.users = users
        
        handleFollow()
        getUser()
    }
    
    
    
    private func handleFollow(){
        guard let token = accessToken else{print("No tokeeeen"); return}

        followButtonRelay
            .flatMapLatest { id -> Observable<(Void,String)> in
                APIUsers.shared.followUser(accessToken: token, userId: id)
                    .map { ($0, id) }
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {[weak self]error in
                        self?.errorPublisher.accept(error)
                        return Observable.empty()
                    }
            }
            .retry()
            .subscribe(onNext: { [weak self] (_, id) in
                self?.getUserRelay.accept(id)
            },onError: {[weak self] error in
                
                self?.errorPublisher.accept(error)
            })
            .disposed(by: disposeBag)
    }
    
    
    func getUser(){
        guard let token = accessToken else{ return}
        
        getUserRelay
            .flatMapLatest { id -> Observable<(UserModel,String)> in
                APIUsers.shared.getOtherUserProfile(by: id, accessToken: token)
                    .map{($0 , id)}
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {[weak self]error in
                        self?.errorPublisher.accept(error)
                        return Observable.empty()
                    }
            }
            .subscribe {[weak self] (user , id) in
                if let index = self?.users.firstIndex(where: { $0.id == Int(id) }) {
                    
                    self?.users.remove(at: index)
                    self?.users.insert(user, at: index)
                }
                self?.reloadTableViewClosure?()
            }
            .disposed(by: disposeBag)
    }


    
    
    func pushProfileScreen(id:String){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.showOtherUsersScreen(id: id)
            
        }else if let coordinator = coordinator as? NotificationCoordinator{
            coordinator.showOtherUsersScreen(id: id)

        }else if let coordinator = coordinator as? SearchCoordinator{
            coordinator.showOtherUsersScreen(id: id)

        }else if let coordinator = coordinator as? ProfileCoordinator{
            coordinator.showOtherUsersScreen(id: id)

        }
    }
}
