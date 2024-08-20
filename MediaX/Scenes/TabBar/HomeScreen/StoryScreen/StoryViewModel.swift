//
//  StoryViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 04/08/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper


class StoryViewModel{
    let disposeBag: DisposeBag
    let coordinator: Coordinator
    let accessToken: String?
    
    
    let getStoriesRelay = PublishRelay<Void>()
    let getStoryDetailsRelay = PublishRelay<(IndexPath,String)>()
    let getViewsRelay = PublishRelay<String>()
    
    var stories : [StoryModel]?

    var reloadTableViewClosure: (() -> Void)?
    var dissmisPickerClosure: (() -> Void)?

    let selectedImageDataRelay = PublishRelay<Data>()

    init(disposeBag: DisposeBag, coordinator: Coordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")
        
        getStories()
        addStory()
        getStoryDetails()
        getStoryViews()
    }
    
    
    
    func getStories(){
        guard let accessToken = accessToken else {
            print("Access token is nil")
            return
        }
        getStoriesRelay
            .flatMapLatest { _ -> Observable<[StoryModel]> in
                return APIStory.shared.getStories(accessToken: accessToken)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] stories in
                self?.stories = stories
                print(stories)
                self?.reloadTableViewClosure?()
            }onError: { error in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)

    }
    
    func addStory(){
        guard let accessToken = accessToken else {
            print("Access token is nil")
            return
        }

        selectedImageDataRelay
            .flatMapLatest { imageData -> Observable<Void> in
                return APIStory.shared.addStory(accessToken: accessToken, imageData: imageData)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] _ in
                self?.reloadTableViewClosure?()
                self?.dissmisPickerClosure?()
            }
            .disposed(by: disposeBag)
    }
    
    func getStoryDetails(){
        guard let accessToken = accessToken else {
            print("Access token is nil")
            return
        }
        getStoryDetailsRelay
            .flatMapLatest { indexPath,id -> Observable<(StoryModel,IndexPath)> in
                
                return APIStory.shared.getStoryDetails(by: id, accessToken: accessToken)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .map { storyDetails in
                        return (storyDetails, indexPath)
                    }
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] details , index in
                
                self?.presentStoryScreen(storyDetials: details, indexPath: index)
            }onError: { error in
                
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)

    }

    
    func getStoryViews(){
        guard let accessToken = accessToken else {
            print("Access token is nil")
            return
        }
        
        getViewsRelay
            .flatMapLatest { id -> Observable<[UserModel]> in
                return APIStory.shared.getStoryViews(accessToken: accessToken, id: id)
                    .observe(on: MainScheduler.instance)
                    .subscribe(on:ConcurrentDispatchQueueScheduler(qos: .background))
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] viewers in
                self?.presentViewersScreen(users: viewers)
            }
            .disposed(by: disposeBag)
            

        
    }
    
    
    
    
    
    
    
    func presentStoryScreen(storyDetials:StoryModel,indexPath:IndexPath){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.presentStoryScreen(details: storyDetials, indexPath:indexPath)
        }
    }
    
    func presentViewersScreen(users:[UserModel]){
        
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.presentStoryViewersScreen(users: users)
        }

    }

}
