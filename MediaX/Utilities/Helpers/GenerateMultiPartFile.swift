//
//  GenerateMultiPartFile.swift
//  MediaX
//
//  Created by Moataz Mohamed on 24/06/2024.
//

import Foundation
import UIKit

struct MultiPartFile {
    
    static func multipartFormDataBody(_ boundary: String,json:[String:Any], images: [UIImage]) -> Data {
        
        
        let lineBreak = "\r\n"
        var body = Data()

        // Adding JSON data

        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])

        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"registerRequestDto\"\(lineBreak)")
        body.append("Content-Type: application/json\(lineBreak + lineBreak)")
        body.append(jsonData)
        body.append(lineBreak)

        // Adding image data
        for image in images {
            if let uuid = UUID().uuidString.components(separatedBy: "-").first {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"imageFile\"; filename=\"\(uuid).jpg\"\(lineBreak)")
                body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
                body.append(image.jpegData(compressionQuality: 0.99)!)
                body.append(lineBreak)
            }
        }

        body.append("--\(boundary)--\(lineBreak)")
        return body
    }


}
