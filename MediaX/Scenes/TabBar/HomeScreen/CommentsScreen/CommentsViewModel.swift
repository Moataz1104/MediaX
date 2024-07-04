//
//  CommentsViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 03/07/2024.
//

import Foundation
import RxSwift
import RxCocoa
class CommentsViewModel{
    let disposeBag: DisposeBag
    let coordinator: HomeCoordinator

    
    init(disposeBag: DisposeBag, coordinator: HomeCoordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
    }
}
