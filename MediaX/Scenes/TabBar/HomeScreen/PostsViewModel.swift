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
    
    let apiService : APIPostsProtocol
    let coordinator: SharedNavigationCoordinatorProtocol
    let accessToken: String?
    
    var posts = [PostModel]()
    let disposeBag = DisposeBag()
    var reloadTableViewClosure: (() -> Void)?
    var reloadTableAtIndex : ((IndexPath) -> Void)?
    
    let errorPublisher = PublishRelay<Error>()
    let likeButtonSubject = PublishRelay<(String,IndexPath)>()
    let commentButtonSubject = PublishRelay<Void>()
    let indicatorPublisher = PublishRelay<Bool>()

    var allPostsDisposable:Disposable?
    var sizeReciver = PublishRelay<Int>()
    
    
    init(apiService: APIPostsProtocol, coordinator: SharedNavigationCoordinatorProtocol) {
        self.apiService = apiService
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
                guard let self = self else{return .empty()}
                self.indicatorPublisher.accept(true)
                return self.apiService.getAllPosts(accessToken: accessToken, size: "\(size)")
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {error in
                        self.errorPublisher.accept(error)
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
                return self.apiService.handleLikes(for: id, accessToken: self.accessToken!)
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
                return self.apiService.getPost(by: id, accessToken: self.accessToken!)
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
        coordinator.showCommentsScreen(post:post)
    }
    
    
    
    func showOtherUserScreen(id:String){
        coordinator.showOtherUsersScreen(id:id)
    }
    
    func showLikesScreen(users:[UserModel]){
        coordinator.PushGeneralScreen(users: users, screenTitle: "\(users.count) Likes",isLikeScreen: true)
    }

    
}
