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
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noData:
            return "No data received from the server"
        case .unknownError:
            return "An unknown error occurred"

        }
    }
}
