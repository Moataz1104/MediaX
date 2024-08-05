//
//  APIStory.swift
//  MediaX
//
//  Created by Moataz Mohamed on 04/08/2024.
//

import Foundation
import RxSwift
import RxCocoa

class APIStory{
    
    static let shared = APIStory()
    private init(){}
    
    
    
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
    
    func getStoryDetails(by id:String,accessToken:String)->Observable<StoryDetailsModel>{
        let urlStr = apiK.getStoryDetailsStr + id
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        return URLSession.shared.rx.response(request: request)
            .flatMapLatest { response,data -> Observable<StoryDetailsModel> in
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
                    let decodedDetails = try JSONDecoder().decode(StoryDetailsModel.self, from: data)
                    return .just(decodedDetails)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }

            }
            .catch { error in
                    .error(NetworkingErrors.networkError(error))
            }
    }
}
