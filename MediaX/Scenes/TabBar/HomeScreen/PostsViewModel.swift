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



class PostsViewModel {
    let disposeBag: DisposeBag
    let coordinator: Coordinator
    let accessToken: String?
    
    var posts = [PostModel]()
    var reloadTableViewClosure: (() -> Void)?
    var reloadTableAtIndex : ((IndexPath) -> Void)?
    
    let errorPublisher = PublishRelay<Error>()
    let likeButtonSubject = PublishRelay<(String,IndexPath)>()
    let commentButtonSubject = PublishRelay<Void>()
    let indicatorPublisher = PublishRelay<Bool>()

    var allPostsDisposable:Disposable?
    var sizeReciver = PublishRelay<Int>()
    
    
    init(disposeBag: DisposeBag, coordinator: Coordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")

        subscribeToLikeButton()
        fetchAllPosts()
    }
    
    func fetchAllPosts() {
        guard let accessToken = accessToken else {
            print("Access token is nil")
            return
        }
        
        sizeReciver
            .flatMapLatest {[weak self] size ->Observable<[PostModel]> in
                self?.indicatorPublisher.accept(true)
                return APIPosts.shared.getAllPosts(accessToken: accessToken, size: "\(size)")
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {[weak self] error in
                        self?.errorPublisher.accept(error)
                        return Observable.empty()
                    }
            }
            .retry()
            .subscribe(
                onNext: { [weak self] posts in
                    self?.posts = posts
                    self?.reloadTableViewClosure?()
                    self?.indicatorPublisher.accept(false)
                },
                onError: { [weak self] error in
                    self?.indicatorPublisher.accept(false)
                    self?.errorPublisher.accept(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    //    MARK: - Post Cell subscribers
    
    private func subscribeToLikeButton() {
        likeButtonSubject
            .flatMapLatest { [weak self] id , indexPath -> Observable<(String,IndexPath)> in
                guard let self = self else { return .empty() }
                return APIInterActions.shared.handleLikes(for: id, accessToken: self.accessToken!)
                    .map { _ in
                        return (id,indexPath)
                    }
                    .catch { error in
                        self.errorPublisher.accept(error)
                        return .empty()
                    }
            }
            .flatMapLatest { [weak self] id , indexPath -> Observable<(PostModel,IndexPath)> in
                guard let self = self else { return .empty() }
                return APIPosts.shared.getPost(by: id, accessToken: self.accessToken!)
                    .map{($0 , indexPath)}
                    .catch { error in
                        self.errorPublisher.accept(error)
                        return .empty()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] post,indexPath in
                guard let self = self else { return }
                if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
                    self.posts[index] = post
                    self.reloadTableAtIndex?(indexPath)
                }
            },onError: {[weak self] error in
                self?.errorPublisher.accept(error)
            })
            .disposed(by: disposeBag)
    }
    
    
    
    
//    MARK: - Navigation
    
    func showCommentsScreen(post:PostModel){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.showCommentsScreen(post:post)
        }else if let coordinator = coordinator as? ProfileCoordinator{
            coordinator.showCommentsScreen(post: post)
        }else if let coordinator = coordinator as? SearchCoordinator{
            coordinator.showCommentsScreen(post: post)
        }else if let coordinator = coordinator as? NotificationCoordinator{
            coordinator.showCommentsScreen(post: post)

        }
    }
    
    
    
    func showOtherUserScreen(id:String){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.showOtherUsersScreen(id:id)
        }
    }

    
}
