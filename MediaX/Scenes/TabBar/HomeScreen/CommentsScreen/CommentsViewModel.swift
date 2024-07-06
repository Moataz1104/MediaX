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
    let disposeBag: DisposeBag
    let coordinator: HomeCoordinator

    let sendButtonRelay = PublishRelay<Void>()
    let contentRelay = PublishRelay<String>()
    let commentAddedPublisher = PublishRelay<Void>()
    let likeButtonRelay = PublishRelay<(String,IndexPath)>()
    
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    let post:PostModel
    var comments = [CommentModel]()
    var reloadTableClosure : ((_ animated:Bool , IndexPath?)-> Void)?
    
    
    init(disposeBag: DisposeBag, coordinator: HomeCoordinator,post:PostModel) {
        self.disposeBag = disposeBag
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

                return APIInterActions.shared.addComment(for: self.post.id!, content: content, accessToken: token)
                    .catch { error in
                        self.coordinator.showErrorInCommentScreen(error)
                        return .empty()
                    }
            }
            .flatMapLatest {[weak self] _ -> Observable<[CommentModel]> in
                guard let self = self else{return .empty()}
                return APIInterActions.shared.getAllComments(by: "\(self.post.id!)", accessToken: token)
                    .catch { error in
                        self.coordinator.showErrorInCommentScreen(error)
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
        APIInterActions.shared.getAllComments(by: "\(post.id!)", accessToken: accessToken!)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] comments in
                self?.comments = comments.reversed()
                self?.reloadTableClosure?(true, nil)
            }onError: {[weak self] error in
                self?.coordinator.showErrorInCommentScreen(error)
            }
            .disposed(by: disposeBag)
            
    }
    
    func addLikeToComment(){
        likeButtonRelay
            .flatMapLatest {[weak self] id , indexPath -> Observable<IndexPath> in
                guard let self = self else{return .empty()}
                return APIInterActions.shared.addLikeToComment(by: id, accessToken: self.accessToken!)
                    .map{indexPath}
                    .catch { error in
                        self.coordinator.showErrorInCommentScreen(error)
                        return .empty()
                    }
            }
            .flatMapLatest {[weak self] indexPath -> Observable<([CommentModel],IndexPath)> in
                guard let self = self else{return .empty()}
                return APIInterActions.shared.getAllComments(by: "\(post.id!)", accessToken: self.accessToken!)
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
                self?.coordinator.showErrorInCommentScreen(error)
            }
            .disposed(by: disposeBag)

            
    }
}
