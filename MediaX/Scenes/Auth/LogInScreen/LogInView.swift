//
//  LogInView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 16/06/2024.
//

import UIKit

class LogInView: UIViewController {

//    MARK: - Attributes
    
    

//    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUi()
        
    }
    
    
    
//    MARK: - Privates
    
    private func configUi(){
        title = "Login"
        let textAttributes: [NSAttributedString.Key:Any] = [
            .foregroundColor : UIColor.main,
            .font : UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

}
