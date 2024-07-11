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
    
    let errorPublisher = PublishRelay<Error>()
    let likeButtonSubject = PublishRelay<String>()
    let commentButtonSubject = PublishRelay<Void>()
    
    
    init(disposeBag: DisposeBag, coordinator: HomeCoordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")

        subscribeToLikeButton()
        
    }
    
    func fetchAllPosts() {
        guard let accessToken = accessToken else {
            print("Access token is nil")
            return
        }
        
        APIPosts.shared.getAllPosts(accessToken: accessToken)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] posts in
                    self?.posts = posts.reversed()
                    self?.reloadTableViewClosure?()
                },
                onError: { [weak self] error in
                    self?.errorPublisher.accept(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    
    //    MARK: - Post Cell subscribers
    
    private func subscribeToLikeButton() {
        likeButtonSubject
            .flatMapLatest { [weak self] id -> Observable<String> in
                guard let self = self else { return .empty() }
                return APIInterActions.shared.handleLikes(for: id, accessToken: self.accessToken!)
                    .map { id }
                    .catch { error in
                        self.errorPublisher.accept(error)
                        return .empty()
                    }
            }
            .flatMapLatest { [weak self] id -> Observable<PostModel> in
                guard let self = self else { return .empty() }
                return APIPosts.shared.getPost(by: id, accessToken: self.accessToken!)
                    .catch { error in
                        self.errorPublisher.accept(error)
                        return .empty()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] post in
                guard let self = self else { return }
                if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
                    self.posts[index] = post
                    self.reloadTableViewClosure?()
                }
            },onError: {[weak self] error in
                self?.errorPublisher.accept(error)
            })
            .disposed(by: disposeBag)
    }
    
    
    
    
//    MARK: - Navigation
    
    func showCommentsScreen(post:PostModel){
        coordinator.showCommentsScreen(post:post)
    }
    
}
