//
//  APIUsers.swift
//  MediaX
//
//  Created by Moataz Mohamed on 12/07/2024.
//

import Foundation
import RxSwift
import RxCocoa

class APIUsers{
    static let shared = APIUsers()
    private init(){}
    
    
    
    
    
    
    func getCurrentUser(accessToken:String)-> Observable<UserModel>{
        let url = apiK.currentUserURL
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.response(request: request)
            .flatMap { response,data -> Observable<UserModel> in
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
                
                
                
            }.catch { error in
                return .error(NetworkingErrors.networkError(error))
                
            }
    }
    func getCurrentUserPosts(accessToken:String)->Observable<[PostModel]>{
        let url = apiK.currentUserPostsURL
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        
        return URLSession.shared.rx.response(request: request)
            .flatMap { response,data -> Observable<[PostModel]> in
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
                    let decodedPosts = try JSONDecoder().decode([PostModel].self, from: data)
                    return .just(decodedPosts)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
                
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
    }
    
    func updateUser(userName:String,phoneNumber:String, bio:String,imageData:Data , accessToken:String)-> Observable<Void>{
        let url = apiK.updateUserURL
        let jsonBody = [
            "fullName" : userName,
            "phoneNumber":phoneNumber,
            "bio":bio
        ]
        
        var request = URLRequest(url: url)
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        
        let body = MultiPartFile.updateUserMultipartFormDataBody(boundary, json: jsonBody, imageData: imageData)
        
        request.httpBody = body
        
        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<Void> in
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
                
                return .just(())
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
    }
    
    func searchUser(userName:String,accessToken:String)-> Observable<[UserModel]>{
                
        let urlString = apiK.searchUserStr + "?userName=\(userName)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data ->Observable<[UserModel]> in
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
                
                do {
                    let decodedUsers = try JSONDecoder().decode([UserModel].self, from: data)
                    return .just(decodedUsers)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
                
            }.catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
        
    }
    
    
    func getOtherUserProfile(by id:String , accessToken:String) -> Observable<UserModel>{
        let urlString = apiK.otherUserProfileStr + id
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response, data -> Observable<UserModel> in
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
    
    func getOtherUserPosts(by id:String , accessToken:String)-> Observable<[PostModel]>{
        let urlString = apiK.otherUserPostsStr + id
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        
        return URLSession.shared.rx.response(request: request)
            .flatMapLatest{response,data -> Observable<[PostModel]> in
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
                    let decodedPosts = try JSONDecoder().decode([PostModel].self, from: data)
                    
                    return .just(decodedPosts)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
    }
    
    
    func followUser(accessToken:String,userId:String)-> Observable<Void>{
        let urlStr = apiK.followUrlString + userId
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<Void> in
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

                return .just(())
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
        

    }
}
