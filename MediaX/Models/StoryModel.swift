//
//  StoryModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 04/08/2024.
//

import Foundation

struct StoryModel:Codable{
    let storyId: Int?
    let username, userImage: String?
    let watched: Bool?
}


struct StoryDetailsModel:Codable{
    let storyImage: String?
    let userId: Int?
    let username, userImage: String?
    let numberOfViews: Int?
    let timeAgo: String?
}
