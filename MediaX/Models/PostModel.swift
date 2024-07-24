//
//  PostModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 02/07/2024.
//

import Foundation

struct PostModel:Codable {
    let id: Int?
    let content: String?
    let image: String?
    let userId: Int?
    let username: String?
    let userImage: String?
    let timeAgo: String?
    let numberOfLikes, numberOfComments: Int?
    let comments: [CommentModel]?
    let liked: Bool?
}
