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
    
    let apiService:APIStoryprotocol
    let coordinator: StoryNavigationCoordinatorProtocol
    let accessToken: String?
    
    
    let disposeBag = DisposeBag()
    let getStoriesRelay = PublishRelay<Void>()
    let getStoryDetailsRelay = PublishRelay<(IndexPath,String)>()
    let getViewsRelay = PublishRelay<String>()
    
    var stories : [StoryModel]?

    var reloadTableViewClosure: (() -> Void)?
    var dissmisPickerClosure: (() -> Void)?

    let selectedImageDataRelay = PublishRelay<Data>()

    init(apiService:APIStoryprotocol, coordinator: StoryNavigationCoordinatorProtocol) {
        self.apiService = apiService
        self.coordinator = coordinator
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")
        
        getStories()
        addStory()
        getStoryDetails()
        getStoryViews()
        getStoriesRelay.accept(())
    }
    
    
    
    func getStories(){
        guard let accessToken = accessToken else {
            print("Access token is nil")
            return
        }
        getStoriesRelay
            .flatMapLatest {[weak self] _ -> Observable<[StoryModel]> in
                guard let self = self else{return .empty()}
                return apiService.getStories(accessToken: accessToken)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch { error in
                        print(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe {[weak self] stories in
                self?.stories = stories
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
            .flatMapLatest {[weak self] imageData -> Observable<Void> in
                guard let self = self else{return .empty()}
                return apiService.addStory(accessToken: accessToken, imageData: imageData)
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
            .flatMapLatest {[weak self] indexPath,id -> Observable<(StoryModel,IndexPath)> in
                guard let self = self else{return .empty()}
                return apiService.getStoryDetails(by: id, accessToken: accessToken)
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
            .flatMapLatest {[weak self] id -> Observable<[UserModel]> in
                guard let self = self else{return .empty()}
                return apiService.getStoryViews(accessToken: accessToken, id: id)
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
    
    
    
    
    
//    MARK: - Navigation
    
    func presentStoryScreen(storyDetials:StoryModel,indexPath:IndexPath){
        coordinator.presentStoryScreen(details: storyDetials, indexPath:indexPath)
    }
    
    func presentViewersScreen(users:[UserModel]){
        coordinator.presentStoryViewersScreen(users: users)
    }

}
