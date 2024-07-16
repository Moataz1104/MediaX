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
        if let image = UIImage(named: image){
            imageAttachment.image = image
        }else if let image = UIImage(systemName: image) {
            let tintedImage = image.withTintColor(.authIcons, renderingMode: .alwaysOriginal)
                imageAttachment.image = tintedImage
            }
        
        imageAttachment.bounds = CGRect(x: 0, y: -7, width: 24, height: 24)
        
        
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        
        let textString = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.authPlaceHolder
        ])
        
        
        let combinedString = NSMutableAttributedString()
        combinedString.append(imageString)
        combinedString.append(NSAttributedString(string: " "))
        combinedString.append(textString)
        
        
        self.attributedPlaceholder = combinedString
    }

}
