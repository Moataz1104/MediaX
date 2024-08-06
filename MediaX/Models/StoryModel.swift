//
//  StoryModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 04/08/2024.
//

import Foundation

struct StoryModel:Codable{
    var storyUploaded:Bool?
    var storyDetails : [StoryDetailsModel]?
}


struct StoryDetailsModel:Codable{
    let id:Int?
    let storyImage: String?
    let userId: Int?
    let storyId: Int?
    let username, userImage: String?
    let numberOfViews: Int?
    let watched: Bool?
    let timeAgo: String?
}


