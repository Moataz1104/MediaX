//
//  NotificationViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 06/08/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper


class NotificationViewModel{
    
    weak var coordinator:NotificationCoordinator?
    let apiService : APINotificationProtocol
    let accessToken: String?

    let disposeBag = DisposeBag()
    let getAllNotificationsRelay = PublishRelay<Void>()
    let getProfileNotiRelay = PublishRelay<(String,String)>()
    let getPostNotiRelay = PublishRelay<(String,String)>()

    var notifications:[NotificationModel]?
    var reloadTableClosure:(() -> Void)?
    
    
    
    init(coordinator: NotificationCoordinator,apiService : APINotificationProtocol) {
        self.coordinator = coordinator
        self.apiService = apiService
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")
        
        
        getAllNotifications()
        getAndReadPostNoti()
        getAndReadProfileNoti()
    }
    
    
    func getAllNotifications(){
        guard let token = accessToken else{return}
        
        getAllNotificationsRelay
            .flatMapLatest {[weak self] _ -> Observable<[NotificationModel]> in
                guard let self = self else{return .empty()}
                return self.apiService.getAllNotifications(token: token)
                    .observe(on: MainScheduler.instance)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] notifications in
                self?.notifications = notifications
                self?.reloadTableClosure?()
            }
            .disposed(by: disposeBag)
    }
    
    func getAndReadProfileNoti(){
        guard let token = accessToken else{return}

        getProfileNotiRelay
            .flatMapLatest {[weak self] userId,notifiId -> Observable<UserModel> in
                guard let self = self else{return .empty()}
                return self.apiService.readAndGetProfileNotification(token: token, userId: userId, notificationId: notifiId)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] user in
                self?.pushProfileScreen(user: user)
                
            }
            .disposed(by: disposeBag)
    }
    
    func getAndReadPostNoti(){
        guard let token = accessToken else{return}

        getPostNotiRelay
            .flatMapLatest {[weak self] postId,notifiId -> Observable<PostModel> in
                guard let self = self else{return .empty()}
                return self.apiService.readAndGetPostNotification(token: token, postId: postId, notificationId: notifiId)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] post in
                self?.pushSinglePostScreen(post: post)
            }
            .disposed(by: disposeBag)
    }

    
    
    func pushProfileScreen(user:UserModel){
        coordinator?.pushProfileScreen(user: user)
    }
    
    func pushSinglePostScreen(post:PostModel){
        coordinator?.pushSinglePostScreen(post: post)
    }

}
