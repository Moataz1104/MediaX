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
    
    let searchTextFieldRelay = PublishRelay<String>()
    init(coordinator: SearchCoordinator, disposeBag: DisposeBag) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        searchForUsers()
    }
    
    
    func searchForUsers() {
        searchTextFieldRelay
            .debounce(RxTimeInterval.milliseconds(200), scheduler: MainScheduler.instance)
            .retry()
            .flatMapLatest { query in
                print(query)
                return APIUsers.shared.searchUser(userName: query, accessToken: "")
            }
            .subscribe(onNext: {[weak self] users in
                self?.users = users
            },onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

}
