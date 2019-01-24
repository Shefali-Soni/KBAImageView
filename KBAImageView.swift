//
//  KBAImageView.swift
//  RIGLYNX
//
//  Created by KBAADMIN on 11/12/17.
//  Copyright © 2017 KBA Sytems. All rights reserved.
//

import UIKit
import AVFoundation
let imageCache = NSCache<NSString, AnyObject>()

class KBAImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //var imageView : UIImageView!
    var defaultImage : UIImage!
    var activity : UIActivityIndicatorView!
    var imgURL : URL!
    var allowFromCache : Bool = true
    var isLandscape : Bool = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit()
    {
        self.backgroundColor = UIColor.white
        
        activity = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        
        activity.hidesWhenStopped = true
        activity.center = self.center
        activity.translatesAutoresizingMaskIntoConstraints = false
        
        let leftSpaceConstraint = NSLayoutConstraint(item: activity, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        
        let topSpaceConstraint = NSLayoutConstraint(item: activity, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: activity, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20)
        
        let heightConstraint = NSLayoutConstraint(item: activity, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20)
        

        self.addSubview(activity)
        self.addConstraints([leftSpaceConstraint, topSpaceConstraint, widthConstraint, heightConstraint])
    }

    func removeURLfromCache(withURL : URL)
    {
        allowFromCache = false
        imgURL = withURL
        if let cachedImage = imageCache.object(forKey: self.imgURL.absoluteString as NSString) as? UIImage {
            imageCache.removeObject(forKey: self.imgURL.absoluteString as NSString)
            print(cachedImage)
        }
    }
    
    func loadImageUsingCache(withURL : URL, placeholderImage : UIImage!) {
        self.image = nil
        imgURL = withURL
        defaultImage = placeholderImage
        DispatchQueue.main.async {
            //self.activity.center = self.center
            self.activity.setNeedsLayout()
            self.activity.startAnimating()
            self.image = nil
        }
       
        
      // check cached image
        if let cachedImage = imageCache.object(forKey: self.imgURL.absoluteString as NSString) as? UIImage {
            if allowFromCache == true
            {
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    if self.imgURL == withURL
                    {
                        self.image = cachedImage
                        self.setNeedsDisplay()
                        if (Int((self.image?.size.width)!) > Int((self.image?.size.height)!))
                        {
                            self.isLandscape = true
                        }
                        else
                        {
                            self.isLandscape = false
                        }
                    }
                }
                
                return
            }
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: self.imgURL!, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                self.activity.stopAnimating()
            }
            if error != nil {
                print(error!)
                DispatchQueue.main.async {
                    self.image = self.defaultImage
                    if self.image != nil
                    {
                        if (Int((self.image?.size.width)!) > Int((self.image?.size.height)!))
                        {
                            self.isLandscape = true
                        }
                        else
                        {
                            self.isLandscape = false
                        }
                    }
                    self.setNeedsDisplay()
                    self.setNeedsLayout()
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
               
                if httpResponse.statusCode == 404
                {
                    DispatchQueue.main.async {
                        self.image = self.defaultImage
                        if self.image != nil
                        {
                            if (Int((self.image?.size.width)!) > Int((self.image?.size.height)!))
                            {
                                self.isLandscape = true
                            }
                            else
                            {
                                self.isLandscape = false
                            }
                            
                        }
                        self.setNeedsDisplay()
                        self.setNeedsLayout()
                        
                    }
                }
            }
            if let image = UIImage(data: data!) {
                
                DispatchQueue.main.async {
                    if self.imgURL == withURL
                    {
                        self.image = image
                        if (Int((self.image?.size.width)!) > Int((self.image?.size.height)!))
                        {
                            self.isLandscape = true
                        }
                        else
                        {
                            self.isLandscape = false
                        }
                        self.setNeedsDisplay()
                        self.setNeedsLayout()
                        imageCache.setObject(image, forKey: self.imgURL.absoluteString as NSString)
                    }
                }
                
            }
            
            
        }).resume()
    }
    
    func loadImageUsingCacheWithCompletion(withURL : URL, placeholderImage : UIImage!, completion : @escaping (Bool)->(Void)) {
        self.image = nil
        imgURL = withURL
        defaultImage = placeholderImage
        DispatchQueue.main.async {
            //self.activity.center = self.center
            self.activity.setNeedsLayout()
            self.activity.startAnimating()
            self.image = nil
        }
        
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: self.imgURL.absoluteString as NSString) as? UIImage {
            if allowFromCache == true
            {
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    if self.imgURL == withURL
                    {
                        self.image = cachedImage
                        self.setNeedsDisplay()
                        self.setNeedsLayout()
                        if (Int((self.image?.size.width)!) > Int((self.image?.size.height)!))
                        {
                            self.isLandscape = true
                        }
                        else
                        {
                            self.isLandscape = false
                        }
                    }
                }
                completion(true)
                return
                
            }
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: self.imgURL!, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                self.activity.stopAnimating()
            }
            if error != nil {
                print(error!)
                DispatchQueue.main.async {
                    self.image = self.defaultImage
                    if self.image != nil
                    {
                        if (Int((self.image?.size.width)!) > Int((self.image?.size.height)!))
                        {
                            self.isLandscape = true
                        }
                        else
                        {
                            self.isLandscape = false
                        }
                    }
                    self.setNeedsDisplay()
                    self.setNeedsLayout()
                    
                }
                completion(true)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 404
                {
                    DispatchQueue.main.async {
                        self.image = self.defaultImage
                        if self.image != nil
                        {
                            if (Int((self.image?.size.width)!) > Int((self.image?.size.height)!))
                            {
                                self.isLandscape = true
                            }
                            else
                            {
                                self.isLandscape = false
                            }
                            
                        }
                        self.setNeedsDisplay()
                        self.setNeedsLayout()
                        
                    }
                    completion(true)
                }
            }
            if let image = UIImage(data: data!) {
                
                DispatchQueue.main.async {
                    if self.imgURL == withURL
                    {
                        self.image = image
                        if (Int((self.image?.size.width)!) > Int((self.image?.size.height)!))
                        {
                            self.isLandscape = true
                        }
                        else
                        {
                            self.isLandscape = false
                        }
                        self .setNeedsDisplay()
                        self.setNeedsLayout()
                        imageCache.setObject(image, forKey: self.imgURL.absoluteString as NSString)
                    }
                }
                completion(true)
            }
            
            
        }).resume()
    }
    
    func loadThumbnailImage(forUrl url: URL, completion : @escaping (Bool)->(Void)) {
        DispatchQueue.main.async {
            self.activity.startAnimating()
        }
        
        let asset: AVAsset = AVAsset(url: url)
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        // let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        
        do {
            DispatchQueue.main.async {
                self.activity.stopAnimating()
            }
            imageGenerator.appliesPreferredTrackTransform = true
            
            let thumbnailImage = try imageGenerator.copyCGImage(at:  CMTimeMake(1, 60) , actualTime: nil)
            let image = UIImage(cgImage: thumbnailImage)
            imageCache.setObject(image, forKey: url.absoluteString as NSString)
            self.image = image
            completion(true)
        } catch let error {
            print(error)
        }
    }
    
//    override func layoutSubviews() {
//        DispatchQueue.main.async {
//            self.activity.center = self.center
//
//
//        }
//    }
}

