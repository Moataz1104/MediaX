//
//  APINotification.swift
//  MediaX
//
//  Created by Moataz Mohamed on 06/08/2024.
//

import Foundation
import RxSwift
import RxCocoa


class APINotification{
    static let shared = APINotification()
    private init(){}
    
    
    
    func getAllNotifications(token:String)-> Observable<[NotificationModel]>{
        
        var request = URLRequest(url: apiK.getNotificationsURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<[NotificationModel]> in
                if !(200..<300).contains(response.statusCode) && response.statusCode != 500 {
                    return .error(NetworkingErrors.serverError(response.statusCode))
                }
                
                if response.statusCode == 500 {
                    do {
                        let decodedMessage = try JSONDecoder().decode(responseErrorsMessage.self, from: data)
                        return .error(NetworkingErrors.customError(decodedMessage.message))
                    } catch {
                        return .error(NetworkingErrors.decodingError(error))
                    }
                }

                do{
                    let decodedNotifications = try JSONDecoder().decode([NotificationModel].self, from: data)
                    return .just(decodedNotifications)
                    
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
            
        
    }
    
    
    func readAndGetProfileNotification(token:String,userId:String,notificationId:String) -> Observable<UserModel>{
        let baseURl = apiK.readNotificationForProfileURL
        var components = URLComponents(url: baseURl, resolvingAgainstBaseURL: false)
        
        let items = [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "notificationId", value: notificationId),
        ]
        components?.queryItems = items
        
        let url = components?.url
        
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

     
        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<UserModel> in
                if !(200..<300).contains(response.statusCode) && response.statusCode != 500 {
                    return .error(NetworkingErrors.serverError(response.statusCode))
                }
                
                if response.statusCode == 500 {
                    do {
                        let decodedMessage = try JSONDecoder().decode(responseErrorsMessage.self, from: data)
                        return .error(NetworkingErrors.customError(decodedMessage.message))
                    } catch {
                        return .error(NetworkingErrors.decodingError(error))
                    }
                }

                do{
                    let decodedUser = try JSONDecoder().decode(UserModel.self, from: data)
                    return .just(decodedUser)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
    }
    
    
    func readAndGetPostNotification(token:String,postId:String,notificationId:String) -> Observable<PostModel>{
        let baseURl = apiK.readNotificationForPostURL
        var components = URLComponents(url: baseURl, resolvingAgainstBaseURL: false)
        
        let items = [
            URLQueryItem(name: "postId", value: postId),
            URLQueryItem(name: "notificationId", value: notificationId),
        ]
        components?.queryItems = items
        
        let url = components?.url
        
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

     
        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<PostModel> in
                if !(200..<300).contains(response.statusCode) && response.statusCode != 500 {
                    return .error(NetworkingErrors.serverError(response.statusCode))
                }
                
                if response.statusCode == 500 {
                    do {
                        let decodedMessage = try JSONDecoder().decode(responseErrorsMessage.self, from: data)
                        return .error(NetworkingErrors.customError(decodedMessage.message))
                    } catch {
                        return .error(NetworkingErrors.decodingError(error))
                    }
                }

                do{
                    let decodedPost = try JSONDecoder().decode(PostModel.self, from: data)
                    return .just(decodedPost)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
    }

}

