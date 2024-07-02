//
//  PostModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 02/07/2024.
//

import Foundation

struct PostModel:Codable {
    let id: Int?
    let content, image, username: String?
    let numberOfLikes, numberOfComments: Int?
    let comments: [CommentModel]?
    let liked: Bool?
    
    
    var imageUrlString : String? {
        guard let image = image else{print("from post model no image"); return nil}
        let baseUrlString = "https://tumbler.onrender.com"
        return baseUrlString + image
    }
}
