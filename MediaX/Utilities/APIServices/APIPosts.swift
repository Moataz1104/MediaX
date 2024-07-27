//
//  APIPosts.swift
//  MediaX
//
//  Created by Moataz Mohamed on 01/07/2024.
//

import Foundation
import SwiftKeychainWrapper
import RxRelay
import RxSwift

class APIPosts {
    static let shared = APIPosts()
    private init() {
        print("apiPosts init")
    }
    

    
    func getAllPosts(accessToken: String,size:String) -> Observable<[PostModel]> {
        print("getallPosts")
        print(accessToken)
        let urlStr = apiK.allPostsPaginatedStr + size
        
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.response(request: request)
            .flatMap { response, data -> Observable<[PostModel]> in
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
                    let decodedData = try JSONDecoder().decode([PostModel].self, from: data)
                    
                    return .just(decodedData)
                } catch {
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                return .error(error)
            }
    }
    
    func getPost(by id: String, accessToken: String) -> Observable<PostModel> {
        let url = URL(string: apiK.getOnePostStringUrl + id)!

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.response(request: request)
            .flatMap { response, data -> Observable<PostModel> in
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
                    let decodedPost = try JSONDecoder().decode(PostModel.self, from: data)
                    return .just(decodedPost)
                } catch {
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                .error(NetworkingErrors.networkError(error))
            }
    }
    
    func addPost( content:String , imageData:Data,accessToken:String) -> Observable<Void>{
        
        var newContent = content
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: apiK.addPostURL)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        if newContent == "Write a caption..."{
            newContent = " "
        }
        
        let body = MultiPartFile.postMultipartFormDataBody(boundary, imageData: imageData, content: newContent)
        request.httpBody = body

        return URLSession.shared.rx.response(request: request)
            .flatMap{response,data -> Observable<Void> in
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
            }.catch { error in
                
                return .error(NetworkingErrors.networkError(error))
            }
    }
}
