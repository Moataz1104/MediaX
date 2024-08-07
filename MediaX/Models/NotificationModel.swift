//
//  NotificationModel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 06/08/2024.
//

import Foundation

struct NotificationModel:Codable{
    let id, fromUserId: Int?
    let fromUserName: String?
    let fromUserImage: String?
    let toUserId: Int?
    let toUserName: String?
    let postId : Int?
    let postImage: String?
    let notificationMessage :String?
    let timeAgo: String?
    let read: Bool?

}
