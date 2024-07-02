//
//  UIImageExtension.swift
//  MediaX
//
//  Created by Moataz Mohamed on 02/07/2024.
//

import Foundation
import UIKit
extension UIImage {
    static func systemImage(named name: String, withSymbolConfiguration scale: UIImage.SymbolScale) -> UIImage? {
        let config = UIImage.SymbolConfiguration(scale: scale)
        return UIImage(systemName: name, withConfiguration: config)
    }
}
