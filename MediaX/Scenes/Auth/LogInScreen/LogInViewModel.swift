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
    let disposeBag:DisposeBag
    
    let emailSubject = PublishSubject<String>()
    let passwordSubject = PublishSubject<String>()
    let errorSubjectMessage = PublishSubject<String>()
    let mainButtonSubject = PublishRelay<Void>()
    let activityIndicatorRelay = BehaviorRelay(value: false)
    
    
    init(coordinator: AuthCoordinator,disposeBag:DisposeBag) {
        self.coordinator = coordinator
        self.disposeBag = disposeBag
        
        subscribeToErrorPublisher()
        subscribeToDataPublisher()

        sendRequest()
    }
    
    
    //    MARK: - Request
    
    private func combineFields() -> Observable<(String,String)> {
        Observable.combineLatest(emailSubject, passwordSubject)
    }
    
    private func sendRequest(){
        mainButtonSubject
            .withLatestFrom(combineFields())
            .do {[weak self]email,password in
                self?.activityIndicatorRelay.accept(true)
                APIAuth.shared.logInUser(email: email, password: password)
                
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        
    }
    
    private func subscribeToErrorPublisher(){
        APIAuth.shared.logInErrorPublisher
            .subscribe {[weak self] event in
                print(event.element?.localizedDescription ?? "")
                self?.errorSubjectMessage.onNext(event.element?.localizedDescription ?? "No Description")
                self?.activityIndicatorRelay.accept(false)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToDataPublisher(){
        APIAuth.shared.resultDataPublisher
            .subscribe { [weak self] event in
                self?.activityIndicatorRelay.accept(false)
                self?.coordinator?.delegate?.didLoginSuccessfully()
            }
            .disposed(by: disposeBag)
    }
    
    //    MARK: - TextFields Validation
    private func isEmailFieldNotEmpty()-> Observable<Bool>{
        emailSubject
            .map{!$0.isEmpty}
    }
    private func isPasswordFieldNotEmpty()-> Observable<Bool>{
        passwordSubject
            .map{!$0.isEmpty}
    }
    
    func isMainButtonDisabled()-> Observable<Bool>{
        Observable
            .combineLatest(isEmailFieldNotEmpty(), isPasswordFieldNotEmpty())
            .map { tf1,tf2 in
                return tf1 && tf2
            }
            .startWith(false)
    }

    
    
    //    MARK: - Navigation
    func pushRegisterScreen(){
        coordinator?.showSignUpScreen()
    }
}
