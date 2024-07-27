//
//  APIInterActions.swift
//  MediaX
//
//  Created by Moataz Mohamed on 04/07/2024.
//

import Foundation
import RxSwift
import RxCocoa

class APIInterActions{
    static let shared = APIInterActions()
    private init(){}
    
    
    
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
                        return .error(NetworkingErrors.customError(decodedMessage.message))
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
    
    func addComment(for id :Int , content:String , accessToken:String)-> Observable<Void>{
        let body = [
            "content":content
        ]
        let jsonBody = try? JSONSerialization.data(withJSONObject: body)
        
        let url = apiK.addCommentStringUrl + "\(id)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody
        
        
        return URLSession.shared.rx.response(request: request)
            .flatMap { response,data ->Observable<Void> in
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
            .catch{error in
                    .error(NetworkingErrors.networkError(error))
            }
    }
    
    func getAllComments(by id : String , accessToken : String)-> Observable<[CommentModel]> {
        let urlString = apiK.commentsStringUrl + id
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.rx.response(request: request)
            .flatMap{response , data -> Observable<[CommentModel]> in
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
                    let decodedData = try JSONDecoder().decode([CommentModel].self, from: data)
                    return .just(decodedData)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch{error in
                return .error(NetworkingErrors.networkError(error))
            }
    }
    
    func addLikeToComment(by id :String, accessToken:String)-> Observable<Void>{
        let urlString = apiK.commentsStringUrl + id + "/like"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

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

            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
    }
}
