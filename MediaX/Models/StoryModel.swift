//
//  StoryModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 04/08/2024.
//

import Foundation

struct StoryModel:Codable{
    let storyID: Int?
    let username, userImage: String?
    let watched: Bool?
}
