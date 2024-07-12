//
//  APIConstants.swift
//  MediaX
//
//  Created by Moataz Mohamed on 20/06/2024.
//

import Foundation

struct apiK{
//    https://tumbler.onrender.com/
    
    static let logInURL =
    URL(string: "https://tumbler.onrender.com/v0/auth/login")!
    static let registerURL =
    URL(string: "https://tumbler.onrender.com/v0/auth/register")!
    static let allPostsPaginatedURL = URL(string: "https://tumbler.onrender.com/v0/posts/paginated-posts?page=0&size=50")!
    static let addPostURL = URL(string: "https://tumbler.onrender.com/v0/posts")!
    static let currentUserURL = URL(string:"https://tumbler.onrender.com/v0/user/profile/current")!
    
    static let getOnePostStringUrl =  "https://tumbler.onrender.com/v0/posts/"
    static let addCommentStringUrl = "https://tumbler.onrender.com/v0/comments/post/"
    static let commentsStringUrl = "https://tumbler.onrender.com/v0/comments/"
    static let likeUrlString = "https://tumbler.onrender.com/v0/likes/post/"

    
    
}
