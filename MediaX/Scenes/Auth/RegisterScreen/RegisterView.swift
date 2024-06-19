//
//  RegisterView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 19/06/2024.
//

import UIKit

class RegisterView: UIViewController {

//    MARK: - Attributes

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPwTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    
    
//    MARK: - View Controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configUi()
        keyBoardWillAppear()
        keyBoardWillDisappear()

    }
//    MARK: - Actions

    @IBAction func registerButtonAction(_ sender: Any) {
    }
    @IBAction func signInButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func viewTapGesture(_ sender: Any) {
        view.endEditing(true)
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
