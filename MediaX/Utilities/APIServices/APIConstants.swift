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
    static let addPostURL = URL(string: "https://tumbler.onrender.com/v0/posts")!
    static let currentUserURL = URL(string:"https://tumbler.onrender.com/v0/user/profile/current")!
    static let currentUserPostsURL = URL(string:"https://tumbler.onrender.com/v0/posts/current_user-posts")!
    static let updateUserURL = URL(string:"https://tumbler.onrender.com/v0/user/profile")!
    static let getStoriesURL = URL(string:"https://tumbler.onrender.com/v0/story/followers")!
    
    static let getOnePostStringUrl =  "https://tumbler.onrender.com/v0/posts/"
    static let addCommentStringUrl = "https://tumbler.onrender.com/v0/comments/post/"
    static let commentsStringUrl = "https://tumbler.onrender.com/v0/comments/"
    static let likeUrlString = "https://tumbler.onrender.com/v0/likes/post/"
    static let otherUserProfileStr = "https://tumbler.onrender.com/v0/user/post/profile/"
    static let otherUserPostsStr = "https://tumbler.onrender.com/v0/posts/user/"
    static let searchUserStr = "https://tumbler.onrender.com/v0/user/search"
    static let allPostsPaginatedStr =  "https://tumbler.onrender.com/v0/posts/paginated-posts?page=0&size="
    static let followUrlString = "https://tumbler.onrender.com/v0/followers/follow/"
    static let deleteUserFromRecentStr = "https://tumbler.onrender.com/v0/user/recent-search/"
    static let getUserFromSearch = "https://tumbler.onrender.com/v0/user/search/profile/"
    static let getStoryDetailsStr = "https://tumbler.onrender.com/v0/story/user/"
    static let getStoryViewsStr = "https://tumbler.onrender.com/v0/story/views/"
    static let getFollowingUsersStr = "https://tumbler.onrender.com/v0/followers/following-details/"
    static let getFollowersUsersStr = "https://tumbler.onrender.com/v0/followers/followers-details/"
}
