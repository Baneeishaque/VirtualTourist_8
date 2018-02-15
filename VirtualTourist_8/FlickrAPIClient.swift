//
//  FlickrAPIClient.swift
//  VirtualTourist_7
//
//  Created by Michelle Grover on 2/4/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit

class FlickrAPIClient: NSObject {
    
    var session = URLSession.shared
    
    func taskForGetPhotos(_ params:[String:AnyObject], completionHandlerForGetPhotosTask: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        
        session = URLSession.shared
        
        // Mark: This is the session configuration and I'm setting the default timeout interval to 45 seconds
        session = setDefaulTimeOutForConfiguration()
        
        
        // Mark: This is the entire url (with parameters) used for the request.
        let request = URLRequest(url: flickrURLRequestFromParameters(params))
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if (error != nil) {
                print("There was an error:\(String(describing: error))")
                completionHandlerForGetPhotosTask(nil, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your statuscode was out of range.")
                completionHandlerForGetPhotosTask(nil, error)
                return
            }
            
            guard let data = data else {
                print("No data was returned")
                completionHandlerForGetPhotosTask(nil, error)
                return
            }
            
            completionHandlerForGetPhotosTask(data, nil)
            
        }
        task.resume()
    }
    
    
    
    
    
    
    // function which uses URLRequest to get the image data
    
    func getImageData (url:String, completionHandler : @escaping (_ data: Data?, _ error: String?) -> ()) {
       
        session = URLSession.shared

        DispatchQueue.main.async {
            if let imageUrl = URL(string: url), let imageData = try? Data(contentsOf:imageUrl) {
                completionHandler(imageData, nil)
            } else {
                completionHandler(nil, "There was an error getting the image")
            }
        }
        
    }
    
    func taskForGetPhotosWithPageNumber(_ params:[String:AnyObject], withPageNumber:Int, completionHandlerForGetPhotosTask: @escaping (_ data:Data?, _ error:Error?) -> ()) {
        
        var methodParamsWithPageNumbers = params
        methodParamsWithPageNumbers["page"] = withPageNumber as AnyObject?
        
        session = URLSession.shared
        
        // Mark: This is the session configuration and I'm setting the default timeout interval to 45 seconds
        session = setDefaulTimeOutForConfiguration()
        
        let request = URLRequest(url: flickrURLRequestFromParameters(methodParamsWithPageNumbers))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if (error != nil) {
                print("There was an error:\(String(describing: error))")
                completionHandlerForGetPhotosTask(nil, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your statuscode was out of range.")
                completionHandlerForGetPhotosTask(nil, error)
                return
            }
            
            guard let data = data else {
                print("No data was returned")
                completionHandlerForGetPhotosTask(nil, error)
                return
            }
            
            completionHandlerForGetPhotosTask(data, nil)
        }
        task.resume()
    }
    
    
    
    
    class func sharedInstance() -> FlickrAPIClient {
        struct Singleton {
            static var sharedInstance = FlickrAPIClient()
        }
        return Singleton.sharedInstance
    }
    
}



extension FlickrAPIClient {
    // Mark: This is the function that sets the sessionConfiguration timeout interval
    
    func setDefaulTimeOutForConfiguration() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 45.0
        sessionConfig.timeoutIntervalForResource = 60.0
        
        return URLSession(configuration: sessionConfig)
    }
    
}

extension FlickrAPIClient {
    
    public func flickrURLRequestFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrAPIClient.Constants.Flickr.APIScheme
        components.host = FlickrAPIClient.Constants.Flickr.APIHost
        components.path = FlickrAPIClient.Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}

var glob_pages:Int!


