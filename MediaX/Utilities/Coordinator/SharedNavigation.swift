//
//  SharedNavigation.swift
//  MediaX
//
//  Created by Moataz Mohamed on 21/08/2024.
//

import Foundation

protocol SharedNavigationCoordinatorProtocol{
    func showCommentsScreen(post:PostModel)
    func showErrorInCommentScreen(_ error: Error)
    func showOtherUsersScreen(id:String)
    func pushPostDetailScreen(posts:[PostModel],indexPath:IndexPath)
    func pushSettingScreen(user:UserModel)
    func PushGeneralScreen(users:[UserModel],screenTitle:String,isLikeScreen:Bool)
}

extension SharedNavigationCoordinatorProtocol{
    func pushSettingScreen(user:UserModel){}
}
