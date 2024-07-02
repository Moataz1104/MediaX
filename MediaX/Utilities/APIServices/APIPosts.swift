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
}
