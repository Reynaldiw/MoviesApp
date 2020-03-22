//
//  ImageViewExtension.swift
//  MoviesApp
//
//  Created by Reynaldi Wijaya on 21/03/20.
//  Copyright © 2020 Reynaldi Wijaya. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadRemoteImage(url: URL) {
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if error != nil {
                return
            }
            
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
