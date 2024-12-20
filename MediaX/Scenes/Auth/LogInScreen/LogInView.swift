//
//  LogInView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 16/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class LogInView: UIViewController {

//    MARK: - Attributes
    private var viewModel : LogInViewModel
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var mainViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

//    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUi()
        
        //Bining
        bindTextFields()
        bindMainButton()
        enablingMainButton()

        activityIndicator.isHidden = true
        subscribeToActivityIndicator()
        
        subscribeToErrorPublisher()

    }
    
    init(viewModel : LogInViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    
//    MARK: - Actions
    
    @IBAction func viewTapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func logInButtonAction(_ sender: Any) {
        print("logInButtonAction")
    }
    
    @IBAction func forgetPwAction(_ sender: Any) {
        print("forgetPwAction")

    }
    @IBAction func signUpButtonAction(_ sender: Any) {
        print("signUpButtonAction")
        viewModel.pushRegisterScreen()
    }
    
    //    MARK: - RX Binding
    private func bindTextFields(){
        emailTextField.rx.controlEvent(.allEvents)
            .subscribe(onNext: { [weak self] in
                guard let text = self?.emailTextField.text else { return }
                self?.viewModel.emailSubject.onNext(text)
            })
            .disposed(by: disposeBag)

        passwordTextField.rx.controlEvent(.allEvents)
            .subscribe(onNext: { [weak self] in
                guard let text = self?.passwordTextField.text else { return }
                self?.viewModel.passwordSubject.onNext(text)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func bindMainButton(){
        logInButton.rx.tap
            .bind(to: viewModel.mainButtonSubject)
            .disposed(by: disposeBag)
    }

    private func enablingMainButton(){
        viewModel.isMainButtonDisabled()
            .bind(to: logInButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func subscribeToActivityIndicator(){
        viewModel.activityIndicatorRelay
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] isAnimating in
                if isAnimating{
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                }else{
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()

                }
            }
            .disposed(by: disposeBag)

    }

    //MARK: - Networking
    
    private func subscribeToErrorPublisher() {
        viewModel.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let error = event.element else {
                    print("Error element is nil")
                    return
                }
                
                let vc: ErrorsAlertView
                if let networkingError = error as? NetworkingErrors {
                    vc = ErrorsAlertView(errorTitleString: networkingError.title, message: networkingError.localizedDescription)
                } else {
                    vc = ErrorsAlertView(errorTitleString: "Error", message: error.localizedDescription)
                }
                
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve

                self?.present(vc, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }

    
    
//    MARK: - Privates
    
    private func configUi(){
        navigationController?.navigationBar.isHidden = true
        mainViewTopCons.constant = view.frame.height * 0.1


        logInButton.layer.cornerRadius = 20
                
        
        mainView.layer.cornerRadius = 40
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        
        emailTextField.setAttributedPlaceholder(with: "Enter your Email address", image: "emailIcon")
        passwordTextField.setAttributedPlaceholder(with: "Enter your Password", image: "pwIcon")

    }
    
}



