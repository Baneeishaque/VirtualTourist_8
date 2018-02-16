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
    
    func getPhotos(params:[String:AnyObject], managedObjectContext:NSManagedObjectContext, pin: PinAnnotation, completionHandler: @escaping (_ success:Bool?, _ error:String?,_ photo:[PinImage]?,_ globalPages:Int?)->()) {
        
        
        taskForGetPhotos(params) { (data, error) in
            if (error != nil) {
                completionHandler(false, error?.localizedDescription, nil, nil)
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
            // Mark: The pages property holds the number of pages returned by the API.
            // Mark: This is also returned by the completionHandler in this function.
            guard let pages = photos["pages"] as? Int else {
                print("Couldn't find the key = pages.")
                return
            }
            
//           glob_pages = pages
            
            //            print("pages:\(pages)")
            
            guard let photo = photos["photo"] as? [[String:AnyObject]] else {
                print("Could not find photo array")
                return
            }
            
//            print("pin lat:\(pin.lat), long:\(pin.long)")
            
            // Mark: This is where photoDictionary value is set
            self.retrievePhotoWithImageData(photoDictionary: photo, managedObjectContext: managedObjectContext, pin: pin, retrievePhotosCompletionHandler: {(photoArray) in
                completionHandler(true, nil, photoArray, pages)
            })
           
        }
    }
    
    
    // Mark: Take the PinImage and add the data to CoreData. Simultaneously, Add those PinImages to an array and pass then back to the completionHandler
    func retrievePhotoWithImageData(photoDictionary:[[String:AnyObject]],managedObjectContext:NSManagedObjectContext, pin:PinAnnotation, retrievePhotosCompletionHandler handler:@escaping (_ photoArray:[PinImage]?) -> ()) {
        
        // This is the place where we will store PinImage in Core Data
        
        var pinImages:[PinImage] = [PinImage]()
        
        DispatchQueue.main.async {
            if (photoDictionary.count == 0) {
                handler(nil)
            } else {
                for item in photoDictionary {
                    if let title = item["title"], let url = item["url_m"] {
                        let pinPhoto = PinImage(title: title as? String, url: url as? String, image: nil, context: managedObjectContext)
                        pinPhoto.pinAnnotation = pin
                        pinImages.append(pinPhoto)
                    }
                }
                do {
                    try managedObjectContext.save()
//                    print("Images Saved!!!!!!")
                } catch {
                    print("There was an error when attempting to save pinImages")
                }
                handler(pinImages)
            }
        }
    }
    
    func getPhotosWithRandomPageNumber(_ params:[String:AnyObject],_ withPageNumber:Int,_ managedObjectContext:NSManagedObjectContext, completionHandler: @escaping (_ success:Bool?, _ error:String?,_ photos:[PinImage]?)->()) {
        
        taskForGetPhotosWithPageNumber(params, withPageNumber: withPageNumber) { (data, error) in
            if (error != nil) {
                completionHandler(false, error?.localizedDescription, nil)
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
            
            
            guard let pages = photos["pages"] as? Int else {
                print("Couldn't find the key = pages.")
                return
            }
            
//            glob_pages = pages
            
            guard let photo = photos["photo"] as? [[String:AnyObject]] else {
                print("Could not find photo array")
                return
            }
            
//            var count:Int = 0
//            
//            for item in photo {
//                count += 1
//            }
//            
//            print("count:\(count)")
//            
//                        print("photoArray:\(photo)")
            
            self.retrieveRandomPhotoImageData(PinImageDictionary: photo, managedObjectContext: managedObjectContext, pinImageCompletionhandler: { (PinImages) in
                
                completionHandler(true, nil, PinImages)
                
            })
            
            
            
            
            
        }
    }
    
    
    func retrieveRandomPhotoImageData(PinImageDictionary:[[String:AnyObject]], managedObjectContext:NSManagedObjectContext, pinImageCompletionhandler handler: @escaping (_ PinImages:[PinImage]?) -> ()) {
        
        var pinImages:[PinImage] = [PinImage]()
        
        DispatchQueue.main.async {
        
            if (PinImageDictionary.count == 0) {
                handler(nil)
            } else {
                for item in PinImageDictionary {
                    if let title = item["title"], let url = item["url_m"] {
                        let pinPhoto = PinImage(title: title as? String, url: url as? String, image: nil, context: managedObjectContext)
                        
                        pinImages.append(pinPhoto)
                    }
                    handler(pinImages)
                }
            }
        }
    }
}





