//
//  AuthResponses.swift
//  MediaX
//
//  Created by Moataz Mohamed on 20/06/2024.
//

import Foundation


struct TokenResponse:Codable{
    let token:String
}
struct AuthErrorsMessage : Codable {
    let message : String
}
