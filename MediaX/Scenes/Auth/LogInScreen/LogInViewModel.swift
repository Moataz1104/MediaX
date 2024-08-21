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
    
    let apiService:APIAuthProtocol
    weak var coordinator : AuthCoordinator?
    
    
    let disposeBag = DisposeBag()
    let emailSubject = PublishSubject<String>()
    let passwordSubject = PublishSubject<String>()
    let errorPublisher = PublishSubject<Error>()
    let mainButtonSubject = PublishRelay<Void>()
    let activityIndicatorRelay = BehaviorRelay(value: false)
    
    
    init(apiService:APIAuthProtocol,coordinator: AuthCoordinator) {
        self.apiService = apiService
        self.coordinator = coordinator
        
        
        subscribeToErrorPublisher()
        subscribeToLogInSuccPublisher()

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
                self?.apiService.logInUser(email: email, password: password)
                
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        
    }
    
    private func subscribeToErrorPublisher(){
        apiService.logInErrorPublisher
            .subscribe {[weak self] error in
                self?.errorPublisher.onNext(error)
                self?.activityIndicatorRelay.accept(false)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToLogInSuccPublisher(){
        apiService.logInSuccessPublisher
            .subscribe { [weak self] event in
                self?.coordinator?.delegate?.didLoginSuccessfully()
                self?.activityIndicatorRelay.accept(false)

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
