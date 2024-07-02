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
    let dataPublisher = PublishRelay<[PostModel]>()
    
    func getAllPosts(accessToken: String) -> Observable<[PostModel]> {
        print("getallPosts")
        print(accessToken)
        
        var request = URLRequest(url: apiK.allPostsPaginatedURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.response(request: request)
            .flatMap { response, data -> Observable<[PostModel]> in
                if !(200..<300).contains(response.statusCode) && response.statusCode != 500 {
                    self.errorPublisher.accept(NetworkingErrors.serverError(response.statusCode).localizedDescription)
                    return .error(NetworkingErrors.serverError(response.statusCode))
                }
                
                if response.statusCode == 500 {
                    do {
                        let decodedMessage = try JSONDecoder().decode(responseErrorsMessage.self, from: data)
                        self.errorPublisher.accept(decodedMessage.message)
                        return .error(NetworkingErrors.serverError(response.statusCode))
                    } catch {
                        self.errorPublisher.accept(NetworkingErrors.decodingError(error).localizedDescription)
                        return .error(NetworkingErrors.decodingError(error))
                    }
                }
                
                do {
                    let decodedData = try JSONDecoder().decode([PostModel].self, from: data)
                    print(decodedData)
                    return .just(decodedData)
                } catch {
                    self.errorPublisher.accept(NetworkingErrors.decodingError(error).localizedDescription)
                    return .error(NetworkingErrors.decodingError(error))
                }
            }
            .catch { error in
                self.errorPublisher.accept(error.localizedDescription)
                return .error(error)
            }
    }
    
    
    func handleLikes(for postId:String,method:String, accessToken:String){
        let url = URL(string: apiK.likeUrlString + postId)

        var request = URLRequest(url: url!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = method
        
        URLSession.shared.dataTask(with: request){[weak self] data,response,error in
            
            if let error = error {
                self?.errorPublisher.accept(NetworkingErrors.networkError(error).localizedDescription)
                print("1")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else{
                self?.errorPublisher.accept(NetworkingErrors.unknownError.localizedDescription)
                print("2")
                return
            }
            guard let data = data else {
                self?.errorPublisher.accept(NetworkingErrors.noData.localizedDescription)
                print("3")
                return
            }
            
            if !(200..<300).contains(httpResponse.statusCode) && httpResponse.statusCode != 500{
                self?.errorPublisher.accept(NetworkingErrors.serverError(httpResponse.statusCode).localizedDescription)
                print("4")
            }
            
            if httpResponse.statusCode == 500 {
                print("5")
                do{
                    let decodedMessage = try JSONDecoder().decode(responseErrorsMessage.self, from: data)
                    self?.errorPublisher.accept(decodedMessage.message)
                    return
                }catch{
                    self?.errorPublisher.accept(NetworkingErrors.decodingError(error).localizedDescription)
                }
            }
            
            print("succsses")

        }.resume()
        


    }
    
}
