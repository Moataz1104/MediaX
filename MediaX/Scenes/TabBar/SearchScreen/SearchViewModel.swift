//
//  SearchViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 16/07/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper

class SearchViewModel{
    
    let coordinator:SearchCoordinator
    let disposeBag:DisposeBag
    
    var users:[UserModel]?
    var recentUsers:[UserModel]?
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    
    let searchTextFieldRelay = PublishRelay<String>()
    let followButtonRelay = PublishRelay<String>()
    let deleteFromRecentRelay = PublishRelay<String>()
    let getUserRelay = PublishRelay<String>()
    let errorPublisher = PublishRelay<Error>()
 
    var reloadTableViewClosure:(()->Void)?
    
    
    
    init(coordinator: SearchCoordinator, disposeBag: DisposeBag) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        searchForUsers()
        handleFollow()
        deleteFromRecent()
        getUser()
    }
    
    
    private func searchForUsers() {
        guard let accessToken = accessToken else{return}
        searchTextFieldRelay
            .debounce(RxTimeInterval.milliseconds(200), scheduler: MainScheduler.instance)
            .retry()
            .flatMapLatest { query -> Observable<(String, [UserModel])> in
                return APIUsers.shared.searchUser(userName: query, accessToken: accessToken)
                    .map { (query, $0) }
                    .catch {[weak self]error in
                        self?.errorPublisher.accept(error)
                        return Observable.empty()
                    }
                
            }
            .subscribe(onNext: {[weak self] (query,users) in
                if query.isEmpty{
                    self?.users = nil
                    self?.recentUsers = users
                    self?.reloadTableViewClosure?()
                }else{
                    self?.recentUsers = nil
                    self?.users = users
                    self?.reloadTableViewClosure?()
                    
                }
            },onError: {[weak self] error in
                self?.errorPublisher.accept(error)
            })
            .disposed(by: disposeBag)
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
    
    

    private func deleteFromRecent() {
        guard let token = accessToken else {
            print("No tokeeeen")
            return
        }

        deleteFromRecentRelay
            .flatMapLatest { id -> Observable<(Void, String)> in
                APIUsers.shared.deleteUserFromRecent(accessToken: token, id: id)
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
                self?.recentUsers?.removeAll(where: { $0.id == Int(id)! })
                self?.reloadTableViewClosure?()
            }, onError: {[weak self] error in
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
                if let index = self?.users?.firstIndex(where: { $0.id == Int(id) }) {
                    print("asdasdasdasdasdasdsa")
                    self?.users?.remove(at: index)
                    self?.users?.insert(user, at: index)
                }
                self?.reloadTableViewClosure?()
            }
            .disposed(by: disposeBag)
    }
    
//    MARK: - Navigation
    
    func pushProfileScree(id:String){
        coordinator.pushProfileScreen(id: id)
    }
}
