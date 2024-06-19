//
//  LogInView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 16/06/2024.
//

import UIKit

class LogInView: UIViewController {

//    MARK: - Attributes
    private var viewModel : LogInViewModel
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var mainViewTopCons: NSLayoutConstraint!
    

//    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUi()
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



