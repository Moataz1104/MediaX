//
//  UIImageExtension.swift
//  MediaX
//
//  Created by Moataz Mohamed on 02/07/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension UIImageView {
    
    func loadImage(url: URL, accessToken: String, indicator: UIActivityIndicatorView?) -> Disposable {
        
        indicator?.isHidden = false
        indicator?.startAnimating()
        
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            DispatchQueue.main.async { [weak self] in
                self?.image = cachedImage
                indicator?.isHidden = true
                indicator?.stopAnimating()
            }
            return Disposables.create()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(memoryCapacity: 40 * 1024 * 1024, diskCapacity: 140 * 1024 * 1024, diskPath: "imageCache")

        let session = URLSession(configuration: configuration)
        
        return session.rx.data(request: request)
            .map { data -> UIImage? in
                return UIImage(data: data)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { [weak self] event in
                switch event {
                case .next(let image):
                    if let image = image {
                        ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
                        DispatchQueue.main.async {
                            self?.image = image
                            indicator?.isHidden = true
                            indicator?.stopAnimating()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.image = nil
                            indicator?.isHidden = true
                            indicator?.stopAnimating()
                        }
                    }
                case .error(let error):
                    print("Error loading image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.image = nil
                    }
                case .completed:
                    break
                }
            }
    }
}

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let maxCacheSize = 20
    
    private init() {
        cache.countLimit = maxCacheSize
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)

    }
    
    func setObject(_ object: UIImage, forKey key: NSString) {
        cache.setObject(object, forKey: key)
    }
    
    func object(forKey key: NSString) -> UIImage? {
        return cache.object(forKey: key)
    }
    
    @objc private func clearCache() {
        cache.removeAllObjects()
    }
}




