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
    
    var reloadTableViewClosure:(()->Void)?
    
    
    
    init(coordinator: SearchCoordinator, disposeBag: DisposeBag) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        searchForUsers()
    }
    
    
    func searchForUsers() {
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

}
