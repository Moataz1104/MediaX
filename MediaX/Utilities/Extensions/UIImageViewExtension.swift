//
//  UIImageExtension.swift
//  MediaX
//
//  Created by Moataz Mohamed on 02/07/2024.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(
        url: URL,
        placeholder: UIImage? = nil,
        resizeTo size: CGSize? = nil,
        completion: ((UIImage?) -> Void)? = nil
    ) {
        // Configure Kingfisher downloader (only needs to be set once)
        let downloader = KingfisherManager.shared.downloader
        downloader.downloadTimeout = 15 // Timeout for image download
        downloader.sessionConfiguration.httpMaximumConnectionsPerHost = 6 // Maximum concurrent downloads per host

        // Configure options for performance
        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.3)), // Smooth fade-in transition
            .cacheOriginalImage, // Store original image in cache
            .backgroundDecode, // Decode images in the background (off the main thread)
            .scaleFactor(UIScreen.main.scale) // Load images for the correct device scale
        ]
        
        // Optionally resize image if size is provided
        if let size = size {
            let processor = ResizingImageProcessor(referenceSize: size, mode: .aspectFill)
            options.append(.processor(processor))
        }
        
        // Show activity indicator
        self.kf.indicatorType = .activity
        
        // Start loading the image
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: options,
            completionHandler: { result in
                switch result {
                case .success(let value):
                    completion?(value.image) // Return the image on success
                case .failure(let error):
                    print("Error loading image: \(error.localizedDescription)")
                    completion?(nil) // Return nil on failure
                }
            }
        )
    }
}
