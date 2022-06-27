//
//  ImageManager.swift
//  P5_weather_app
//
//  Created by Alvaro Choque on 21/6/22.
//

import Foundation
import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>)-> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.sync {
                        completion(.success(image))
                    }
                }
            }
        }
    }
}

//extension UIImageView {
//    func load(url: URL) {
//        DispatchQueue.global().async {
//
//            if let data = try? Data(contentsOf: url) {
//
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self.image = image
//                    }
//                }
//            }
//        }
//    }
//}
