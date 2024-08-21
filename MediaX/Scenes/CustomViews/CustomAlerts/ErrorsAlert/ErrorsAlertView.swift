//
//  ErrorsAlertView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 06/07/2024.
//

import UIKit

class ErrorsAlertView: UIViewController {

    @IBOutlet weak var errorTitle: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    
    let errorTitleString:String
    let message:String
    
    init( errorTitleString: String, message: String) {
        self.errorTitleString = errorTitleString
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorTitle.text = errorTitleString
        self.errorMessage.text = message
        contentView.layer.cornerRadius = 40
        okButton.layer.cornerRadius = okButton.frame.height / 2
    }

    

    @IBAction func okButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
