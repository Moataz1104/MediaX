//
//  UserModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 12/07/2024.
//

import Foundation

struct UserModel:Codable{
    let fullName, email, phoneNumber: String?
    let username : String?
    let id:Int?
    let image: String?
    let userId:Int?
    let userImage:String?
    let bio: String?
    let follow: Bool?
    let numberOfPosts, numberOfFollowing, numberOfFollowers: Int?
    let timeAgo:String?
    
}
