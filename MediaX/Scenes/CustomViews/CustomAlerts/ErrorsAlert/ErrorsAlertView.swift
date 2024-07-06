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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.cornerRadius = 40
        okButton.layer.cornerRadius = okButton.frame.height / 2
    }


    @IBAction func okButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
