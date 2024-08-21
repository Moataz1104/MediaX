//
//  APIStory.swift
//  MediaX
//
//  Created by Moataz Mohamed on 04/08/2024.
//

import Foundation
import RxSwift
import RxCocoa


protocol APIStoryprotocol{
    func getStories(accessToken:String)-> Observable<[StoryModel]>
    func addStory(accessToken:String,imageData:Data)-> Observable<Void>
    func getStoryDetails(by id:String,accessToken:String)->Observable<StoryModel>
    func getStoryViews(accessToken:String,id:String)-> Observable<[UserModel]>
}


class APIStory:APIStoryprotocol{
    
    func getStories(accessToken:String)-> Observable<[StoryModel]>{
        
        var request = URLRequest(url: apiK.getStoriesURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<[StoryModel]> in
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
                    let decodedStories = try JSONDecoder().decode([StoryModel].self, from: data)
                    return .just(decodedStories)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
    }
    
    func addStory(accessToken:String,imageData:Data)-> Observable<Void>{
        let boundary = "Boundary-\(UUID().uuidString)"
        let body = MultiPartFile.addStoryMultipartFormDataBody(boundary: boundary, imageData: imageData)
        
        var request = URLRequest(url: apiK.addStoryURL)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
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
    
    func getStoryDetails(by id:String,accessToken:String)->Observable<StoryModel>{
        let urlStr = apiK.getStoryDetailsStr + id
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<StoryModel> in
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
                    let decodedDetails = try JSONDecoder().decode(StoryModel.self, from: data)
                    return .just(decodedDetails)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }

            }
            .catch { error in
                    .error(NetworkingErrors.networkError(error))
            }
    }
    
    func getStoryViews(accessToken:String,id:String)-> Observable<[UserModel]>{
        let urlStr = apiK.getStoryViewsStr + id
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<[UserModel]> in
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
                    let decodedViews = try JSONDecoder().decode([UserModel].self, from: data)
                    return .just(decodedViews)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                return .error(NetworkingErrors.networkError(error))
            }
        
    }
}
