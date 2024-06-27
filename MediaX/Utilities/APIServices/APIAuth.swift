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


class APIAuth {
    static let shared = APIAuth()
    private init(){}
    
//    for log in
    let logInErrorPublisher = PublishRelay<String>()
    let logInSuccessPublisher = PublishRelay<Void>()

//    for register
    let registerErrorStringPublisher = PublishRelay<String>()
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
                self?.logInErrorPublisher.accept(NetworkingErrors.networkError(error).localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else{
                self?.logInErrorPublisher.accept(NetworkingErrors.unknownError.localizedDescription)
                return
            }
            guard let data = data else {
                self?.logInErrorPublisher.accept(NetworkingErrors.noData.localizedDescription)
                return
            }
            
            if !(200..<300).contains(httpResponse.statusCode) && httpResponse.statusCode != 500{
                self?.logInErrorPublisher.accept(NetworkingErrors.serverError(httpResponse.statusCode).localizedDescription)
            }
            
            if httpResponse.statusCode == 500 {
                do{
                    let decodedMessage = try JSONDecoder().decode(AuthErrorsMessage.self, from: data)
                    self?.logInErrorPublisher.accept(decodedMessage.message)
                    return
                }catch{
                    self?.logInErrorPublisher.accept(NetworkingErrors.decodingError(error).localizedDescription)
                }
            }

            
            
            
            print("Request successful. Response data: \(data)")
            do {
                let response = try JSONDecoder().decode(TokenResponse.self, from: data)
                self?.logInSuccessPublisher.accept(())
                let _:Bool = KeychainWrapper.standard.set(response.token, forKey: "token")
                UserDefaults.standard.set(Date(), forKey: "loginTimestamp")
                print(response.token)
            } catch {
                print("Error decoding response: \(error)")
                self?.logInErrorPublisher.accept(NetworkingErrors.decodingError(error).localizedDescription)
            }
            
            

        }.resume()
        

    }
    
    func registerUser(userName: String, email: String, password: String, images: [UIImage] = [UIImage(named:"profileIcon")!]) {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: apiK.registerURL)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let phoneNumber = "01123433" + String(Int.random(in: 100...999))
        
        let jsonData: [String: Any] = [
            "fullName": userName,
            "email": email,
            "password": password,
            "phoneNumber":phoneNumber,
        ]

        
        let body = MultiPartFile.multipartFormDataBody(boundary, json: jsonData, images: images)
        
        request.httpBody = body

        
        URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error)")
                    self?.registerErrorStringPublisher.accept(NetworkingErrors.networkError(error).localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else{
                    self?.registerErrorStringPublisher.accept(NetworkingErrors.unknownError.localizedDescription)
                    return
                }
                guard let data = data else {
                    self?.registerErrorStringPublisher.accept(NetworkingErrors.noData.localizedDescription)
                    return
                }

                if !(200..<300).contains(httpResponse.statusCode) && httpResponse.statusCode != 500{
                    self?.registerErrorStringPublisher.accept(NetworkingErrors.serverError(httpResponse.statusCode).localizedDescription)
                }
                
                if httpResponse.statusCode == 500 {
                    do{
                        let decodedMessage = try JSONDecoder().decode(AuthErrorsMessage.self, from: data)
                        self?.registerErrorStringPublisher.accept(decodedMessage.message)
                        return
                    }catch{
                        self?.registerErrorStringPublisher.accept(NetworkingErrors.decodingError(error).localizedDescription)
                    }
                }
                
                _ = String(data: data, encoding: .utf8)
                self?.registerSuccessPublisher.accept(())
            }
        }.resume()
    }

    
    
}


