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
    
    var stories : [StoryModel]?
    var reloadTableViewClosure: (() -> Void)?
    var reloadTableViewClosure2: (() -> Void)?

    init(disposeBag: DisposeBag, coordinator: Coordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
        self.accessToken = KeychainWrapper.standard.string(forKey: "token")
        
        getStories()
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
                self?.reloadTableViewClosure?()
                self?.reloadTableViewClosure2?()

            }onError: { error in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)

    }
    
    
    
    
    
    
    
    
    
    
    
    
    func presentStoryScreen(indexPath:IndexPath){
        if let coordinator = coordinator as? HomeCoordinator{
            coordinator.presentStoryScreen(indexPath:indexPath)
        }
    }

}
