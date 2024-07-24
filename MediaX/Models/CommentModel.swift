//
//  CommentModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 02/07/2024.
//

import Foundation

struct CommentModel:Codable{
    let id: Int?
    let content: String?
    let userId: Int?
    let username: String?
    let userImage: String?
    let timeAgo: String?
    let liked: Bool?

}
