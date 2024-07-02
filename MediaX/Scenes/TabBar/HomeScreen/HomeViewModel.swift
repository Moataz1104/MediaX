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

    
    let errorPublisher = PublishRelay<String>()
    let postsPublisher = PublishRelay<[PostModel]>()
    
    var posts = [PostModel]()
    var reloadTableViewClosure: (() -> Void)?

    init(disposeBag: DisposeBag, coordinator: HomeCoordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")
        
        
        
        subscribeToErrorPublisher()
        subscribeToGetPostsPublisher()
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
    
        
}
