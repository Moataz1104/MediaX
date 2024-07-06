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
    
    
    let accessToken = KeychainWrapper.standard.string(forKey: "token")
    let post:PostModel
    var comments = [CommentModel]()
    var reloadTableClosure : (()-> Void)?
    
    
    init(disposeBag: DisposeBag, coordinator: HomeCoordinator,post:PostModel) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.post = post
        
        addComment()
        getAllComments()
    }
    
    
    
    
    func addComment(){
        guard let token = accessToken else {print("No token"); return}
        sendButtonRelay
            .withLatestFrom(contentRelay)
            .subscribe{[weak self] content in
                guard let self = self else{return}
                if let content = content.element{
                    APIInterActions.shared.addComment(for: self.post.id!, content: content, accessToken: token)
                        .observe(on: MainScheduler.instance)
                        .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
                        .subscribe { _ in
                            print("Comment Added ")
                        }onError: { error in
                            print(error.localizedDescription)
                        }
                        .disposed(by: disposeBag)
                    
                    commentAddedPublisher.accept(())
                }
            }
            .disposed(by: disposeBag)
    }
    
    func getAllComments(){
        APIInterActions.shared.getAllComments(by: "\(post.id!)", accessToken: accessToken!)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] comments in
                self?.comments = comments.reversed()
                self?.reloadTableClosure?()
            }onError: { error in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
            
    }
}
