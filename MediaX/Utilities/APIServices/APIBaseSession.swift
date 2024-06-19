//
//  APIBaseRequest.swift
//  MediaX
//
//  Created by Moataz Mohamed on 20/06/2024.
//

import Foundation

struct APIBaseSession{
    
    static func baseSession(request:URLRequest,completion: @escaping (Result<Data?,Error>) ->Void){

        
        let session = URLSession.shared
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "InvalidResponse", code: 0)))
                return
            }
            if (200..<300).contains(httpResponse.statusCode) {
                completion(.success(data))
                return
            }else{
                print("HTTP Error: \(httpResponse.statusCode)")
                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode)))
                return
            }
        }
        .resume()
        
    }
    
    
}
