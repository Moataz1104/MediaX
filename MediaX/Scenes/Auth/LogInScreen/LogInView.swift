//
//  LogInView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 16/06/2024.
//

import UIKit

class LogInView: UIViewController {

//    MARK: - Attributes
    
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

    }
    
    
    
//    MARK: - Privates
    
    private func configUi(){
        navigationController?.navigationBar.isHidden = true
        mainViewTopCons.constant = view.frame.height * 0.1


        logInButton.layer.cornerRadius = 20
                
        
        mainView.layer.cornerRadius = 40
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        
    }

}
