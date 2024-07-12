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
    weak var coordinator:ProfileCoordinator?
    let disposeBag:DisposeBag
    
    var user:UserModel?
    var reloadcollectionViewClosure:(()->Void)?
    let isAnimatingPublisher = PublishRelay<Bool>()
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    init(coordinator: ProfileCoordinator, disposeBag: DisposeBag) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        
        
        getCurrentUser()
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
            }onError: { error in
                print(error.localizedDescription)
                self.isAnimatingPublisher.accept(false)

            }
            .disposed(by: disposeBag)
    }
    
}
