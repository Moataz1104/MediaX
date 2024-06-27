//
//  DataExtension.swift
//  MediaX
//
//  Created by Moataz Mohamed on 24/06/2024.
//

import Foundation


extension Data {
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
