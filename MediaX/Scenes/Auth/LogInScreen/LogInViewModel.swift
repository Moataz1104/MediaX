//
//  LogInViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 19/06/2024.
//

import Foundation
import RxSwift
import RxCocoa

class LogInViewModel {
    weak var coordinator : AuthCoordinator?
    
    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }
    
    
    func pushRegisterScreen(){
        coordinator?.showSignUpScreen()
    }
}
