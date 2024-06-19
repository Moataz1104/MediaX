//
//  UITextFieldExtension.swift
//  MediaX
//
//  Created by Moataz Mohamed on 19/06/2024.
//

import Foundation

import UIKit

extension UITextField {
    
    func setAttributedPlaceholder(with text: String, image:String) {
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: image)
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
        
        
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        
        let textString = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.authIcons
        ])
        
        
        let combinedString = NSMutableAttributedString()
        combinedString.append(imageString)
        combinedString.append(NSAttributedString(string: " "))
        combinedString.append(textString)
        
        
        self.attributedPlaceholder = combinedString
    }

}
