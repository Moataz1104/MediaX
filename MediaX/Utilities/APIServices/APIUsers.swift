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
                        return .error(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: decodedMessage.message]))
                    } catch {
                        return .error(NetworkingErrors.decodingError(error))
                    }
                }
                
                do{
                    let decodedUser = try JSONDecoder().decode(UserModel.self, from: data)
                    print(decodedUser)
                    return .just(decodedUser)
                }catch{
                    return .error(NetworkingErrors.decodingError(error))
                }
                
                

            }.catch { error in
                return .error(NetworkingErrors.networkError(error))

            }
        
        
        
        
    }
    
}
