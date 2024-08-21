//
//  APIAuth.swift
//  MediaX
//
//  Created by Moataz Mohamed on 20/06/2024.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftKeychainWrapper
import UIKit


protocol APIAuthProtocol{
    //    for log in
    var logInErrorPublisher : PublishRelay<Error>{get}
    var logInSuccessPublisher : PublishRelay<Void>{get}

    //    for register
    var registerErrorPublisher : PublishRelay<Error>{get}
    var registerSuccessPublisher : PublishRelay<Void>{get}
    
    func logInUser(email: String, password: String)
}

extension APIAuthProtocol{
    func registerUser(userName: String, email: String, password: String, images: [UIImage] = [UIImage(named:"profileIcon")!]){
        
    }
}


class APIAuth : APIAuthProtocol{
    
    let logInErrorPublisher = PublishRelay<Error>()
    let logInSuccessPublisher = PublishRelay<Void>()
    let registerErrorPublisher = PublishRelay<Error>()
    let registerSuccessPublisher = PublishRelay<Void>()

    

    
    func logInUser(email: String, password: String){
        let body = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: apiK.logInURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request){[weak self] data,response,error in
            
            if let error = error {
                self?.logInErrorPublisher.accept(NetworkingErrors.networkError(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else{
                self?.logInErrorPublisher.accept(NetworkingErrors.unknownError)
                return
            }
            guard let data = data else {
                self?.logInErrorPublisher.accept(NetworkingErrors.noData)
                return
            }
            
            if !(200..<300).contains(httpResponse.statusCode) && httpResponse.statusCode != 500{
                self?.logInErrorPublisher.accept(NetworkingErrors.serverError(httpResponse.statusCode))
            }
            
            if httpResponse.statusCode == 500 {
                do{
                    let decodedMessage = try JSONDecoder().decode(responseErrorsMessage.self, from: data)
                    self?.logInErrorPublisher.accept(NSError(domain: "", code: 500,userInfo: [NSLocalizedDescriptionKey:decodedMessage.message]))
                    return
                }catch{
                    self?.logInErrorPublisher.accept(NetworkingErrors.decodingError(error))
                }
            }

            
            
            
            do {
                let response = try JSONDecoder().decode(TokenResponse.self, from: data)
                let _:Bool = KeychainWrapper.standard.set(response.token, forKey: "token")
                self?.logInSuccessPublisher.accept(())
                UserDefaults.standard.set(Date(), forKey: "loginTimestamp")
                
            } catch {
                print("Error decoding response: \(error)")
                self?.logInErrorPublisher.accept(NetworkingErrors.decodingError(error))
            }
            
            

        }.resume()
        

    }
    
    func registerUser(userName: String, email: String, password: String, images: [UIImage] = [UIImage(named:"profileIcon")!]) {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: apiK.registerURL)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonData: [String: Any] = [
            "fullName": userName,
            "email": email,
            "password": password,
        ]

        
        let body = MultiPartFile.registerMultipartFormDataBody(boundary, json: jsonData, images: images)
        
        request.httpBody = body

        
        URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error)")
                    self?.registerErrorPublisher.accept(NetworkingErrors.networkError(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else{
                    self?.registerErrorPublisher.accept(NetworkingErrors.unknownError)
                    return
                }
                guard let data = data else {
                    self?.registerErrorPublisher.accept(NetworkingErrors.noData)
                    return
                }

                if !(200..<300).contains(httpResponse.statusCode) && httpResponse.statusCode != 500{
                    self?.registerErrorPublisher.accept(NetworkingErrors.serverError(httpResponse.statusCode))
                }
                
                if httpResponse.statusCode == 500 {
                    do{
                        let decodedMessage = try JSONDecoder().decode(responseErrorsMessage.self, from: data)
                        self?.registerErrorPublisher.accept(NSError(domain: "", code: 500,userInfo: [NSLocalizedDescriptionKey:decodedMessage.message]))
                        return
                    }catch{
                        self?.registerErrorPublisher.accept(NetworkingErrors.decodingError(error))
                    }
                }
                
                _ = String(data: data, encoding: .utf8)
                self?.registerSuccessPublisher.accept(())
            }
        }.resume()
    }

    
    
}


