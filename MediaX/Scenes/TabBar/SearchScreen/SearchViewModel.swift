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
//    let getUserRelay = PublishRelay<(Void,String)>()
    var reloadTableViewClosure:(()->Void)?
    
    
    
    init(coordinator: SearchCoordinator, disposeBag: DisposeBag) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        searchForUsers()
        handleFollow()
        deleteFromRecent()
    }
    
    
    private func searchForUsers() {
        guard let accessToken = accessToken else{return}
        searchTextFieldRelay
            .debounce(RxTimeInterval.milliseconds(200), scheduler: MainScheduler.instance)
            .retry()
            .flatMapLatest { query -> Observable<(String, [UserModel])> in
                return APIUsers.shared.searchUser(userName: query, accessToken: accessToken)
                    .map { (query, $0) }
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
            },onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    private func handleFollow(){
        guard let token = accessToken else{print("No tokeeeen"); return}

        followButtonRelay
            .flatMapLatest { id -> Observable<Void> in
                APIUsers.shared.followUser(accessToken: token, userId: id)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .do(onError:{error in
                        print(error.localizedDescription)
                    })
            }
            .retry()
            .subscribe {[weak self] _ in
                
                self?.reloadTableViewClosure?()
            }onError: { error in
                
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }

    private func deleteFromRecent(){
        guard let token = accessToken else{print("No tokeeeen"); return}

        deleteFromRecentRelay
            .flatMapLatest { id -> Observable<Void> in
                APIUsers.shared.deleteUserFromRecent(accessToken: token, id: id)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .do(onError:{error in
                        print(error.localizedDescription)
                    })
            }
            .retry()
            .subscribe {[weak self] _ in
                
                self?.reloadTableViewClosure?()
            }onError: { error in
                
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
//    private func getUser(){
//        guard let token = accessToken else{return}
//        
//        getUserRelay
//            .flatMapLatest { _ , id -> Observable<UserModel> in
//                return APIUsers.shared.getUserFromSearch(by: id, accessToken: token)
//                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
//                    .observe(on: MainScheduler.instance)
//                    .do(onError:{error in print(error.localizedDescription)})
//            }
//            .subscribe {[weak self] user in
//                
//            }
//            
//        
//    }

    
//    MARK: - Navigation
    
    func pushProfileScree(id:String){
        coordinator.pushProfileScreen(id: id)
    }
}
