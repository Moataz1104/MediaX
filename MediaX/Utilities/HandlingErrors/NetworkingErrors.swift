//
//  NetworkingErrors.swift
//  MediaX
//
//  Created by Moataz Mohamed on 27/06/2024.
//

import Foundation

enum NetworkingErrors : Error {
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case noData
    case unknownError
    
    var localizedDescription:String {
        switch self {
        case .networkError(let error):
            return "\(error.localizedDescription)"
        case .decodingError(let error):
            return "\(error.localizedDescription)"
        case .serverError(let statusCode):
            return "status code: \(statusCode)"
        case .noData:
            return "No data received from the server"
        case .unknownError:
            return "An unknown error occurred"

        }
    }
    
    var title:String{
        switch self {
        case .networkError(_):
            return "Network error"
        case .decodingError(_):
            return "Decoding error"
        case .serverError(_):
            return "Server error"
        case .noData:
            return "No data"
        case .unknownError:
            return "An unknown"
        }
    }
}
