//
//  UserModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 12/07/2024.
//

import Foundation

struct UserModel:Codable{
    let fullName, email, phoneNumber: String?
    let image: String?
    let bio: String?
    let followStatus: String?
    let numberOfPosts, numberOfFollowing, numberOfFollowers: Int?

}
