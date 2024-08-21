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
    
    let apiService:APIUsersprotocol
    let coordinator:SearchNavigationProtocol
    
    
    let disposeBag = DisposeBag()
    var users:[UserModel]?
    var recentUsers:[UserModel]?
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    
    let searchTextFieldRelay = PublishRelay<String>()
    let followButtonRelay = PublishRelay<String>()
    let deleteFromRecentRelay = PublishRelay<String>()
    let getUserRelay = PublishRelay<String>()
    let errorPublisher = PublishRelay<Error>()
 
    var reloadTableViewClosure:(()->Void)?
    
    
    
    init(apiService:APIUsersprotocol,coordinator: SearchNavigationProtocol) {
        self.apiService = apiService
        self.coordinator = coordinator
        
        
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
            .flatMapLatest {[weak self] query -> Observable<(String, [UserModel])> in
                guard let self = self else{return .empty()}
                return apiService.searchUser(userName: query, accessToken: accessToken)
                    .map { (query, $0) }
                    .catch {error in
                        self.errorPublisher.accept(error)
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
            .flatMapLatest {[weak self] id -> Observable<(Void,String)> in
                guard let self = self else{return .empty()}
                return apiService.followUser(accessToken: token, userId: id)
                    .map { ($0, id) }
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {error in
                        self.errorPublisher.accept(error)
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
            .flatMapLatest {[weak self] id -> Observable<(Void, String)> in
                guard let self = self else{return .empty()}
                return apiService.deleteUserFromRecent(accessToken: token, id: id)
                    .map { ($0, id) }
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {error in
                        self.errorPublisher.accept(error)
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
            .flatMapLatest {[weak self] id -> Observable<(UserModel,String)> in
                guard let self = self else{return .empty()}
                return apiService.getOtherUserProfile(by: id, accessToken: token)
                    .map{($0 , id)}
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {error in
                        self.errorPublisher.accept(error)
                        return Observable.empty()
                    }
            }
            .subscribe {[weak self] (user , id) in
                if let index = self?.users?.firstIndex(where: { $0.id == Int(id) }) {
                    
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
