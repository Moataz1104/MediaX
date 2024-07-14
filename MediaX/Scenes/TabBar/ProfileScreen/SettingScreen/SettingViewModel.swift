//
//  SettingViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 14/07/2024.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel{
    let disposeBag:DisposeBag
    let coordinator : ProfileCoordinator
    
    init(disposeBag: DisposeBag, coordinator: ProfileCoordinator) {
        self.disposeBag = disposeBag
        self.coordinator = coordinator
    }
}
