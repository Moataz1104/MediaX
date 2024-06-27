//
//  RegisterView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 19/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterView: UIViewController {
    
    //    MARK: - Attributes
    
    private var viewModel : RegisterViewModel
    let disposeBag: DisposeBag
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPwTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    
    //    MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUi()
        keyBoardWillAppear()
        keyBoardWillDisappear()
        
        //Bining
        bindTextFields()
        bindMainButton()
        enablingMainButton()
        
        //TextFields Validation
        userNameValidation()
        emailValidation()
        passwordValidation()
        confirmingPasswords()
        
        //Networking
        showingNetworkErrorAlert()
        showingRegisterAlert()
        
        activityIndicator.isHidden = true
        subscribeToActivityIndicator()
        
        
    }
    
    init(viewModel : RegisterViewModel,disposeBag: DisposeBag){
        self.viewModel = viewModel
        self.disposeBag = disposeBag
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: - Actions
    
    @IBAction func registerButtonAction(_ sender: Any) {
        view.endEditing(true)
    }
    @IBAction func signInButtonAction(_ sender: Any) {
        viewModel.popToLogInScreen()
    }
    @IBAction func viewTapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
    //    MARK: - RX Binding
    
    private func bindTextFields(){
        nameTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let text = self?.nameTextField.text else { return }
                self?.viewModel.userNameSubject.onNext(text)
            })
            .disposed(by: disposeBag)
        
        emailTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let text = self?.emailTextField.text else { return }
                self?.viewModel.emailSubject.onNext(text)
            })
            .disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let text = self?.passwordTextField.text else { return }
                self?.viewModel.passwordSubject.onNext(text)
            })
            .disposed(by: disposeBag)
        
        confirmPwTextField.rx.controlEvent(.editingDidEnd)
            .map { [weak self] in
                self?.confirmPwTextField.text ?? ""
            }
            .filter { !$0.isEmpty } // Filter out empty strings
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.confirmPasswordSubject.onNext(text)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    private func enablingMainButton(){
        viewModel.isMainButtonDisabled()
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func bindMainButton(){
        registerButton.rx.tap
            .bind(to: viewModel.mainButtonSubject)
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
    
    
    //    MARK: - TextFields Validation
    
    private func userNameValidation(){
        viewModel.isUserNameValid()
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] isValid in
                if !isValid {
                    self?.present(Validation.popAlert(alertType: .invalidUerName), animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func emailValidation(){
        viewModel.isEmailValid()
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] isValid in
                if !isValid {
                    self?.present(Validation.popAlert(alertType: .invalidEmail), animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func passwordValidation(){
        viewModel.isPasswordValid()
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] isValid in
                if !isValid  {
                    self?.present(Validation.popAlert(alertType: .invalidPassword), animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func confirmingPasswords(){
        viewModel.arePasswordsEqual()
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] areValid in
                if !areValid{
                    self?.present(Validation.popAlert(alertType: .passwordNotEqual), animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    //    MARK: - Networking Functions
    private func showingNetworkErrorAlert(){
        viewModel
            .errorSubjectMessage
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] errorMessage in
                let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func showingRegisterAlert(){
        viewModel
            .showRegisterAlertSubject
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] _ in
                let vc = RegisterAlertView(nibName: "RegisterAlertView", bundle: nil)

                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                
                // Presenting from the current view controller
                self?.present(vc, animated: true, completion: nil)

                DispatchQueue.main.asyncAfter(deadline: .now() + 6){
                    vc.dismiss(animated: true)
                }
                
            }
            .disposed(by: disposeBag)
    }
    
    
    //    MARK: - Privates
    private func configUi(){
        
        navigationController?.navigationBar.isHidden = true
        
        scrollViewTopCons.constant = view.frame.height * 0.1
        scrollView.layer.cornerRadius = 40
        scrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        nameTextField.setAttributedPlaceholder(with: "Enter your full name", image: "personIcon")
        emailTextField.setAttributedPlaceholder(with: "Enter your Email address", image: "emailIcon")
        passwordTextField.setAttributedPlaceholder(with: "Enter your Password", image: "pwIcon")
        confirmPwTextField.setAttributedPlaceholder(with: "confirm password", image: "pwIcon")
        
        
        registerButton.layer.cornerRadius = 20
        
        
    }
    
    //    Handle keyBoard appearance to stretch the scroll view
    private func keyBoardWillAppear(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func keyBoardWillDisappear(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardAppear(notification : NSNotification){
        if let keyBoardFrame : NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyBoardHeight = keyBoardFrame.cgRectValue.height
            scrollView.contentInset.bottom = keyBoardHeight
        }
    }
    
    @objc func keyBoardDisappear(){
        scrollView.contentInset = .zero
    }
    
    
    
}
