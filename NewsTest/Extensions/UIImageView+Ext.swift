//
//  UIImageView+Ext.swift
//  NewsTest
//
//  Created by Zac Johnson on 1/10/20.
//  Copyright © 2020 Zac Johnson. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingURLString(urlString: String) {
        let url = URL(string: urlString)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
        }
    }
    
	func loadImageFromCacheWithUrlString(urlString: String, withPlaceholder placeholder: String) {
        
        self.image = UIImage(named: placeholder)
        
        // Check cache for cached image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // Otherwise, download image
        loadImage(urlString: urlString)
    }
	
	func loadImage(urlString: String) {
		let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
				DispatchQueue.main.async {
					self.image = UIImage(named: "rocketeers.png")					
				}
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
            }
            
        }).resume()
	}
}


