//
//  RegisterViewModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 19/06/2024.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel {
    let disposeBag : DisposeBag
    weak var coordinator : AuthCoordinator?
    
    let userNameSubject = PublishSubject<String>()
    let emailSubject = PublishSubject<String>()
    let passwordSubject = PublishSubject<String>()
    let confirmPasswordSubject = PublishSubject<String>()
    let errorSubjectMessage = PublishSubject<String>()
    let mainButtonSubject = PublishRelay<Void>()
    let activityIndicatorRelay = BehaviorRelay(value: false)


    init(coordinator: AuthCoordinator,disposeBage : DisposeBag) {
        self.coordinator = coordinator
        self.disposeBag = disposeBage
        
        subscribeToErrorPublisher()
        subscribeToRegisterSuccPublisher()
        
        sendRequest()
    }
    


    //    MARK: - TextFields Validation
    func isUserNameValid() -> Observable<Bool>{
        userNameSubject
            .map(Validation.isValidUserName(_:))
    }
    
    func isEmailValid() -> Observable<Bool>{
        emailSubject
            .map(Validation.isValidEmail(_:))
    }

    func isPasswordValid() -> Observable<Bool>{
        passwordSubject
            .map(Validation.isPasswordValid(_:))
    }
    
    func arePasswordsEqual()-> Observable<Bool>{
        Observable.combineLatest(passwordSubject, confirmPasswordSubject)
            .flatMapLatest { password, confirmPassword in
                return Observable.just(password == confirmPassword)
            }

    }
    
    func isMainButtonDisabled()-> Observable<Bool>{
        Observable
            .combineLatest(isUserNameValid(), isEmailValid(), isPasswordValid(), arePasswordsEqual())
            .map { tf1,tf2,tf3,tf4 in
                return tf1 && tf2 && tf3 && tf4
            }
            .startWith(false)
    }

    
//    MARK: - Request
    
    private func combineFields() -> Observable<(String,String,String)> {
        Observable.combineLatest(userNameSubject, emailSubject, passwordSubject)
    }
    
    private func sendRequest(){
        mainButtonSubject
            .withLatestFrom(combineFields())
            .do {[weak self] userName,email,password in
                self?.activityIndicatorRelay.accept(true)
                print(userName,email,password)
                APIAuth.shared.registerUser(userName: userName, email: email, password: password)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func subscribeToErrorPublisher(){
        APIAuth.shared.registerErrorStringPublisher
            .subscribe {[weak self] message in
                
                self?.errorSubjectMessage.onNext(message)
                self?.activityIndicatorRelay.accept(false)

            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToRegisterSuccPublisher(){
        APIAuth.shared.registerSuccessPublisher
            .subscribe { [weak self] event in
                self?.activityIndicatorRelay.accept(false)

            }
            .disposed(by: disposeBag)
    }

    
//    MARK: - Navigation
    
    func popToLogInScreen(){
        coordinator?.popVC()
    }
}
