//
//  FlickrAPIConvenience.swift
//  VirtualTourist_7
//
//  Created by Michelle Grover on 2/4/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData

extension FlickrAPIClient {
    
    func getPhotos(_ params:[String:AnyObject], managedObjectContext:NSManagedObjectContext, completionHandler: @escaping (_ success:Bool?, _ error:String?,_ photo:[PinImage]?)->()) {
        
        
        taskForGetPhotos(params) { (data, error) in
            if (error != nil) {
                completionHandler(false, error?.localizedDescription, nil)
                return
            }
            
            guard let _ = data else {
                print("Some of the data wasn't retrieved")
                return
            }
            
            let parsedResult:[String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Couldn't parse data:'\(String(describing: data))'")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                print("Flickr returned an error. Error code and status are '\(parsedResult)'")
                return
            }
            
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                print("Cannot find key in parsedResult = photos")
                return
            }
            
            //print("photos:\(photos)")
            
            guard let pages = photos["pages"] as? Int else {
                print("Couldn't find the key = pages.")
                return
            }
            
            glob_pages = pages
            
            //            print("pages:\(pages)")
            
            guard let photo = photos["photo"] as? [[String:AnyObject]] else {
                print("Could not find photo array")
                return
            }
            
            // Mark: This is where photoDictionary value is set
            self.retrievePhotoWithImageDataNewVersion(photo, managedObjectContext: managedObjectContext, completionHandler: {(photoArray) in
                completionHandler(true, nil, photoArray)
            })
           
        }
    }
    
    func retrievePhotoWithImageDataNewVersion(_ photoDictionary:[[String:AnyObject]],managedObjectContext:NSManagedObjectContext, completionHandler handler:@escaping (_ photoArray:[PinImage]?) -> ()) {
        
        // This is the place where we will store PinImage in Core Data
        
        var pinImages:[PinImage] = [PinImage]()
        
        DispatchQueue.main.async {
            if (photoDictionary.count == 0) {
                handler(nil)
            }else {
                for item in photoDictionary {
                    if let title = item["title"], let url = item["url_m"] {
                        let pinPhoto = PinImage(title: title as! String, url: url as! String, image: nil, context: managedObjectContext)
                        pinImages.append(pinPhoto)
                    }
                }
                handler(pinImages)
            }
        }
    }
    
    
    
    
    
    
    
}



