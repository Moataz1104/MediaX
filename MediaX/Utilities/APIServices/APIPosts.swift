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
    
    let errorPublisher = PublishRelay<String>()
    let onePostPublisher = PublishRelay<PostModel>()

    
    func getAllPosts(accessToken: String) -> Observable<[PostModel]> {
        print("getallPosts")
        print(accessToken)
        
        var request = URLRequest(url: apiK.allPostsPaginatedURL)
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
                        return .error(NSError(domain: "", code: 500,userInfo: [NSLocalizedDescriptionKey:decodedMessage.message]))
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
                        return .error(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: decodedMessage.message]))
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



    
    
    func handleLikes(for postId: String, accessToken: String) -> Observable<Void> {
        let url = URL(string: apiK.likeUrlString + postId)!

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        return URLSession.shared.rx.response(request: request)
            .flatMap{ response,data -> Observable<Void> in
                
                if !(200..<300).contains(response.statusCode) && response.statusCode != 500 {
                    return .error(NetworkingErrors.serverError(response.statusCode))
                }
                if response.statusCode == 500 {
                    do {
                        let decodedMessage = try JSONDecoder().decode(responseErrorsMessage.self, from: data)
                        return .error(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: decodedMessage.message]))
                    } catch {
                        return .error(NetworkingErrors.decodingError(error))
                    }
                }

                return .just(())

            }
            .catch { error in
                    .error(NetworkingErrors.networkError(error))
            }
        
        
    }

}
