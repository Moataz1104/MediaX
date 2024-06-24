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


class APIAuth {
    static let shared = APIAuth()
    private init(){}
    
//    for log in
    let logInErrorPublisher = PublishRelay<Error>()
    let resultDataPublisher = PublishSubject<Any>()
    
//    for register
    let registerErrorStringPublisher = PublishRelay<String>()

    
    var accessToken = ""
    
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

        APIBaseSession.baseSession( request: request) {[weak self] result in
            switch result{
            case .success(let data):
                if let data = data{
                    print("Request successful. Response data: \(data)")
                    do {
                        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
                        self?.resultDataPublisher.onNext(response)
                        self?.accessToken = response.token
                        let _:Bool = KeychainWrapper.standard.set(response.token, forKey: "token")
                        UserDefaults.standard.set(Date(), forKey: "loginTimestamp")
                        print(response.token)
                    } catch {
                        print("Error decoding response: \(error)")
                        self?.logInErrorPublisher.accept(error)
                    }
                    
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                self?.logInErrorPublisher.accept(error)
            }
        }
    }
    
    func registerUser(userName:String,email: String, password: String){
        print("Request sent")
        let body = [
            "userProfileUpdateDto": [
                "fullName": userName,
                "email":email,
                "password":password,
                "phoneNumber": "01123433300",
                "bio": "testtest"
            ]
        ]
        var request = URLRequest(url: apiK.registerURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData

        APIBaseSession.baseSession(request:request) {[weak self] result in
            switch result{
            case .success(let data):
                if let data = data{
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                        
                        if responseString.contains("Registration successful") {
                            print("Registration was successful")
                            
                        } else {
                            print("Unexpected response: \(responseString)")
                            self?.registerErrorStringPublisher.accept(responseString)

                        }
                    } else {
                        print("Unable to convert data to string")
                        self?.registerErrorStringPublisher.accept("Error")

                    }

                    
                    
                }
            case .failure(let error):
                print("Request failed with error: \(error.localizedDescription)")
                self?.registerErrorStringPublisher.accept(error.localizedDescription)
            }
        }
    }

    
    
    
}
