//
//  CommentsViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 03/07/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper

class CommentsViewModel{
    
    let coordinator: Coordinator
    let apiService:APIInCommentsProtocol
    
    let disposeBag = DisposeBag()
    let sendButtonRelay = PublishRelay<Void>()
    let contentRelay = PublishRelay<String>()
    let commentAddedPublisher = PublishRelay<Void>()
    let likeButtonRelay = PublishRelay<(String,IndexPath)>()
    
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    let post:PostModel
    var comments = [CommentModel]()
    var reloadTableClosure : ((_ animated:Bool , IndexPath?)-> Void)?
    
    
    init( apiService:APIInCommentsProtocol,coordinator: Coordinator,post:PostModel) {
        self.apiService = apiService
        self.coordinator = coordinator
        self.post = post
        
        
        addComment()
        getAllComments()
        addLikeToComment()
        
        
    }
    
    func addComment(){
        guard let token = accessToken else {print("No token"); return}

        sendButtonRelay
            .withLatestFrom(contentRelay)
            .flatMapLatest {[weak self] content -> Observable<Void> in
                guard let self = self else{return .empty()}
                self.commentAddedPublisher.accept(())

                return self.apiService.addComment(for: self.post.id!, content: content, accessToken: token)
                    .catch { error in
                        self.showError(error: error)
                        return .empty()
                    }
            }
            .flatMapLatest {[weak self] _ -> Observable<[CommentModel]> in
                guard let self = self else{return .empty()}
                return self.apiService.getAllComments(by: "\(self.post.id!)", accessToken: token)
                    .catch { error in
                        self.showError(error: error)
                        return .empty()
                    }
            }
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] comments in
                self?.comments = comments.reversed()
                self?.reloadTableClosure?(true,nil)
            }
            .disposed(by: disposeBag)


    }
    
    func getAllComments(){
        self.apiService.getAllComments(by: "\(post.id!)", accessToken: accessToken!)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] comments in
                self?.comments = comments.reversed()
                self?.reloadTableClosure?(true, nil)
            }onError: {[weak self] error in
                self?.showError(error: error)
            }
            .disposed(by: disposeBag)
            
    }
    
    func addLikeToComment(){
        likeButtonRelay
            .flatMapLatest {[weak self] id , indexPath -> Observable<IndexPath> in
                guard let self = self else{return .empty()}
                return self.apiService.addLikeToComment(by: id, accessToken: self.accessToken!)
                    .map{indexPath}
                    .catch { error in
                        self.showError(error: error)
                        return .empty()
                    }
            }
            .flatMapLatest {[weak self] indexPath -> Observable<([CommentModel],IndexPath)> in
                guard let self = self else{return .empty()}
                return self.apiService.getAllComments(by: "\(post.id!)", accessToken: self.accessToken!)
                    .map { comments in (comments.reversed(), indexPath) }
            }
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                let (comments, indexPath) = result
                self.comments = comments
                self.reloadTableClosure?(false, indexPath)
            } onError: {[weak self] error in
                self?.showError(error: error)
            }
            .disposed(by: disposeBag)

            
    }
    
    func showError(error:Error){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.showErrorInCommentScreen(error)
        }else if let coordinator = coordinator as? ProfileCoordinator{
            coordinator.showErrorInCommentScreen(error)

        }else if let coordinator = coordinator as? SearchCoordinator{
            coordinator.showErrorInCommentScreen(error)

        }else if let coordinator = coordinator as? NotificationCoordinator{
            coordinator.showErrorInCommentScreen(error)

        }
    }
    
    func showLikesScreen(users:[UserModel]){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.PushGeneralScreen(users: users, screenTitle: "\(users.count) Likes",isLikeScreen: true)
        }else if let coordinator = coordinator as? ProfileCoordinator{
            coordinator.PushGeneralScreen(users: users, screenTitle: "\(users.count) Likes",isLikeScreen: true)

        }else if let coordinator = coordinator as? SearchCoordinator{
            coordinator.PushGeneralScreen(users: users, screenTitle: "\(users.count) Likes",isLikeScreen: true)

        }else if let coordinator = coordinator as? NotificationCoordinator{
            coordinator.PushGeneralScreen(users: users, screenTitle: "\(users.count) Likes",isLikeScreen: true)

        }

    }
    
    func showOtherUserScreen(id:String){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.showOtherUsersScreen(id:id)
        }else if let coordinator = coordinator as? ProfileCoordinator{
            coordinator.showOtherUsersScreen(id:id)

        }else if let coordinator = coordinator as? SearchCoordinator{
            coordinator.showOtherUsersScreen(id:id)

        }else if let coordinator = coordinator as? NotificationCoordinator{
            coordinator.showOtherUsersScreen(id:id)

        }
    }



}
