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
    let likeButtonSubject = PublishRelay<String>()
    let commentButtonSubject = PublishRelay<Void>()
    
    var postIndex : Int?
    
    
    init(disposeBag: DisposeBag, coordinator: HomeCoordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")
        
        
        
        subscribeToErrorPublisher()
        subscribeToGetOnePostPublisher()
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
                    self?.posts = posts
                    self?.reloadTableViewClosure?()
                },
                onError: { [weak self] error in
                    self?.errorPublisher.accept(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func fetchOnePost(by id:String,index:Int){
        guard let accessToken = accessToken else {
            errorPublisher.accept("Access token is nil")
            return
        }
        APIPosts.shared.getPost(by: id, accessToken: accessToken)
        postIndex = index
    }
    
    // MARK: - API subscribers
    
    private func subscribeToGetOnePostPublisher() {
        APIPosts.shared.onePostPublisher
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] post in
                print("post from view model : \(post)")
                if let index = self?.postIndex{
                    self?.posts.remove(at: index)
                    self?.posts.insert(post, at: index)
                    self?.reloadTableViewClosure?()
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    private func subscribeToErrorPublisher() {
        APIPosts.shared.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.errorPublisher.accept(errorMessage)
                print(errorMessage)
            })
            .disposed(by: disposeBag)
    }
    //    MARK: - Post Cell subscribers
    
    private func subscribeToLikeButton(){
        likeButtonSubject
            .subscribe {[weak self] id in
                guard let self = self else {return}
                APIPosts.shared.handleLikes(for: id, accessToken: self.accessToken!)
                self.fetchAllPosts()
                
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
