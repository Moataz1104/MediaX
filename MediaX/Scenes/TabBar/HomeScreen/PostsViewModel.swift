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


protocol PostsViewModelDelegate:AnyObject{
    func didTapCommentButtonInProfile(post:PostModel)
}

class PostsViewModel {
    let disposeBag: DisposeBag
    let coordinator: Coordinator
    let accessToken: String?
    weak var delegate:PostsViewModelDelegate?
    
    var posts = [PostModel]()
    var reloadTableViewClosure: (() -> Void)?
    
    let errorPublisher = PublishRelay<Error>()
    let likeButtonSubject = PublishRelay<String>()
    let commentButtonSubject = PublishRelay<Void>()
    let indicatorPublisher = PublishRelay<Bool>()

    var allPostsDisposable:Disposable?
    
    init(disposeBag: DisposeBag, coordinator: Coordinator) {
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
        indicatorPublisher.accept(true)
        allPostsDisposable?.dispose()
        allPostsDisposable = APIPosts.shared.getAllPosts(accessToken: accessToken)
            .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
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
    
    func showCommentsScreenFromHome(post:PostModel){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.showCommentsScreen(post:post)
        }
    }
    
    func showCommentsScreenFromProfile(post:PostModel){
        delegate?.didTapCommentButtonInProfile(post:post)
    }
    
    func presentStoryScreen(indexPath:IndexPath){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.presentStoryScreen(indexPath:indexPath)
        }
    }
    
    func showOtherUserScreen(id:String){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.showOtherUsersScreen(id:id)
        }
    }

    
}
