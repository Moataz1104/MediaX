//
//  SettingViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 14/07/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper
class SettingViewModel{
    
    let disposeBag:DisposeBag
    let coordinator : ProfileCoordinator
    let user:UserModel

    let userNameRelay = PublishRelay<String>()
    let phoneNumberRelay = PublishRelay<String>()
    let bioRelay = PublishRelay<String>()
    let imageDataPublisher = PublishRelay<Data>()
    let updateButtonRelay = PublishRelay<Void>()
    let isUpdateButtonHiddenPublisher = PublishRelay<Bool>()
    let indicatorPublisher = PublishRelay<Bool>()
    
    
    let token = KeychainWrapper.standard.string(forKey: "token")
    
    var dismissView:(()->Void)?
    var resetUserInfo:(()-> Void)?
    
    init(disposeBag: DisposeBag, coordinator: ProfileCoordinator,user:UserModel) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.user = user
        subscribeToUserName()
        sendUpdates()
    }
    
    func subscribeToUserName(){
        userNameRelay
            .subscribe {[weak self] userName in
                if let name = userName.element{
                    self?.isUpdateButtonHiddenPublisher.accept(name.isEmpty)
                }
            }
            .disposed(by: disposeBag)
    }
    func combinedFields() -> Observable<(String,String,String,Data)>{
        Observable.combineLatest(userNameRelay, phoneNumberRelay, bioRelay,imageDataPublisher)
            
    }
    func sendUpdates() {
        guard let token = token else { return }
        
        updateButtonRelay
            .withLatestFrom(combinedFields())
            .flatMapLatest { [weak self] userName, phone, bio, imageData -> Observable<Void> in
                self?.indicatorPublisher.accept(true)
                return APIUsers.shared.updateUser(userName: userName, phoneNumber: phone, bio: bio, imageData: imageData, accessToken: token)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .do(onError: { error in
                        self?.indicatorPublisher.accept(false)
                        self?.coordinator.showErrorInSettingScreen(error)
                        self?.resetUserInfo?()
                        print(error.localizedDescription)
                    })
                    .retry() 
            }
            .subscribe(onNext: { [weak self] _ in
                self?.dismissView?()
                self?.indicatorPublisher.accept(false)
            })
            .disposed(by: disposeBag)
    }

    
}
