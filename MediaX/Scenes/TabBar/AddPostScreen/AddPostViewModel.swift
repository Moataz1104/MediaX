//
//  AddPostViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 10/07/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper


class AddPostViewModel{
    let apiService : APIPostsProtocol
    weak var coordinator:AddPostCoordinator?
    
    let token = KeychainWrapper.standard.string(forKey: "token")
    var selectedImageData: Data?

    var successClosure:(()->Void)?
    let disposeBag = DisposeBag()
    let contentTextViewBinder = PublishRelay<String>()
    let postButtonBinder = PublishRelay<Void>()
    let indicatorPublisher = PublishRelay<Bool>()
    let errorPublisher = PublishRelay<Error>()

    init(apiService : APIPostsProtocol,coordinator: AddPostCoordinator) {
        self.apiService = apiService
        self.coordinator = coordinator
            
        addPost()
        
    }
    
    
    func addPost() {
        guard let token = token else { print("No token"); return }

        postButtonBinder
            .withLatestFrom(contentTextViewBinder)
            .flatMapLatest { [weak self] content -> Observable<Void> in
                guard let self = self, let imageData = self.selectedImageData else { return .empty() }
                self.indicatorPublisher.accept(true)
                
                return self.apiService.addPost(content: content, imageData: imageData, accessToken: token)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .observe(on: MainScheduler.instance)
                    .catch {error  in
                        self.indicatorPublisher.accept(false)
                        self.errorPublisher.accept(error)
                        return .empty()
                    }
            }
            .retry()
            .subscribe(
                onNext: { [weak self] in
                    self?.successClosure?()
                    self?.indicatorPublisher.accept(false)
                    self?.clearState()
                }
            )
            .disposed(by: disposeBag)
    }

    func clearState() {
        selectedImageData = nil
        contentTextViewBinder.accept("")
    }

}
