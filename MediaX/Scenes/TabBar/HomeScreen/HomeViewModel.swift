//
//  HomeViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 28/06/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper

class HomeViewModel {
    let disposeBag: DisposeBag
    let coordinator: HomeCoordinator
    let accessToken: String?
    
    var posts = [PostModel]()
    var reloadTableViewClosure: (() -> Void)?

    let errorPublisher = PublishRelay<String>()
    let postsPublisher = PublishRelay<[PostModel]>()
    let likeButtonSubject = PublishRelay<(String,String)>()
    let commentButtonSubject = PublishRelay<Void>()

    


    init(disposeBag: DisposeBag, coordinator: HomeCoordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")
        
        
        
        subscribeToErrorPublisher()
        subscribeToGetPostsPublisher()
        subscribeToLikeButton()
        
        fetchAllPosts()
    }
    
    private func fetchAllPosts() {
        guard let accessToken = accessToken else {
            errorPublisher.accept("Access token is nil")
            return
        }
        
        APIPosts.shared.getAllPosts(accessToken: accessToken)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] posts in
                    self?.postsPublisher.accept(posts)
                },
                onError: { [weak self] error in
                    self?.errorPublisher.accept(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: - API subscribers
    
    private func subscribeToGetPostsPublisher() {
        postsPublisher
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                self?.posts = Array(posts[5...])
                self?.reloadTableViewClosure?()
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToErrorPublisher() {
        errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.errorPublisher.accept(errorMessage)
            })
            .disposed(by: disposeBag)
    }
//    MARK: - Post Cell subscribers

        private func subscribeToLikeButton(){
            likeButtonSubject
                .subscribe {[weak self] id,method in
                    guard let self = self else {return}
                    APIPosts.shared.handleLikes(for: id, method: method, accessToken: self.accessToken!)
                }
                .disposed(by: disposeBag)

        }
        private func subscribeToCommentButton(){
            commentButtonSubject
                .subscribe { _ in
                    
                }
                .disposed(by: disposeBag)
        }


        
}
