//
//  ViewController.swift
//  VirtualTourist_8
//
//  Created by Michelle Grover on 2/10/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapDetailViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
   
    // Mark: The locationAnnotation data that is passed from MapViewController
    var locationAnnotation:MKAnnotation!
    // Mark: Array for method parameters required for the API call
    var methodParameters:[String:AnyObject]!
    // Mark: Declaration of the delegate used to access CoreDataStack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    // Mark: FetchedResultsController declaration
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    // Mark: This property is for the current PinAnnotation
    var pin:PinAnnotation?
    // Mark: declaration of PinImages variable
    var pinImages:[PinImage]!
    // Mark: This variable is used in the getCoreDataPinImages function.
    var coreDataPinImages:[PinImage]!
    
    var totalNumberOfPages:Int!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mark: Set the mapView delegate
        mapView.delegate = self
        setSpanAndRegion()
        setAnnotation()
        
        collectionViewDelegateAndDataSource()
        flowLayoutSetUp()
       
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Mark pin is the current PinAnnotation for the PinImages
        pin = self.getCurrentPinAnnotation(locationAnnotation)
        

        
        // Mark: This function decides whether to call getArrayOfPhotos. If there are no PinImages in CoreData then call API else if there are PinImages in CoreData then do not call api. Retrieve the Data from CoreData
        shouldCallGetArrayOfPhotos()
        
    }
    
    

    @IBAction func getRandomPhotoPage(_ sender: Any) {
//        print("totalNumberOfPages:\(totalNumberOfPages)")
        // Mark: This gets the random photos from the API call. Nothing is saved to CoreData
        getRandomImagesForPin()
    }
    


}
// Mark: CoreData functionality is located here
extension MapDetailViewController {
    
    // Mark: Returns a Bool value that tells if CoreData has a PinImage for the PinAnnotation
    func isCoreDataImagePresent(pin:PinAnnotation) -> Bool {
        if (getCoreDataPinImages(pin: pin)?.count == 0) {
            return false
        }
        return true
    }
    
    // Mark: This function decides if it is appropriate to call getArrayOfPhotos
    // Mark: This is also where I set the totalNumberOfPhotos property. This is used to decide when I need to disable the newCollection button.
    func shouldCallGetArrayOfPhotos() {
        if (!isCoreDataImagePresent(pin: pin!)) {
//            print("Call API and save images to CoreData")
            // Mark: This function makes the API call
            // Mark: this function retrieves the PinImage data from the Flickr API and puts PinImage data into the pinImages array
            getArrayOfPhotos(theLocation: locationAnnotation)
        } else {
//            print("Get Images from CoreData")
            // Mark: This function retrieves PinImage data from CoreData and puts the values in the pinImages array
            self.pinImages = getCoreDataPinImages(pin: pin!)
            totalNumberOfPages = self.pinImages.count
            // Mark: We can retrieve the totalNumberOfPhotos when the images are in CoreData
//            print("totalNumberOfPages:\(self.totalNumberOfPages)")
            disableNewCollectionButtonIfNoPhotos(numberOfPages: self.totalNumberOfPages)
            
        }
    }
    
    // Mark: Disable the new Collection button if the number of photos is <= 18
    func disableNewCollectionButtonIfNoPhotos(numberOfPages:Int) {
        if (numberOfPages <= 20) {
            self.newCollectionButton.isEnabled = false
        } else {
            self.newCollectionButton.isEnabled = true
        }
    }
    
    func getCoreDataPinImages(pin:PinAnnotation) -> [PinImage]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinImage")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let pred = NSPredicate(format: "pinAnnotation = %@", pin)
        fetchRequest.predicate = pred
        
        do {
            // Mark: coreDataPinImages is declared at the top of the controller because if I declare it in the function it will be a let property and it has to be a var.
            self.coreDataPinImages = try getCoreDataStack().context.fetch(fetchRequest) as! [PinImage]
        } catch {
            print("There was an error retrieving images")
        }
        return coreDataPinImages
        
//        for item in coreDataPinImages {
//            print("title:\(item.title), url:\(item.url)")
//        }
    
    }
    
    
    
    
    // Mark: This function retrieves the CoreDataStack
    func getCoreDataStack() -> CoreDataStack {
        let stack = delegate.stack
        return stack
    }
    
    // Mark: Step 1. Get the actual current PinAnnotation
    func getCurrentPinAnnotation(_ annotation:MKAnnotation) -> PinAnnotation? {
        var myAnnotation:PinAnnotation?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]
        let pred = NSPredicate(format: "lat = %lf AND long = %lf", annotation.coordinate.latitude, annotation.coordinate.longitude)
        fetchRequest.predicate = pred
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.getCoreDataStack().context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            let results = try fetchedResultsController?.managedObjectContext.fetch(fetchRequest) as! [PinAnnotation]
            
            if  results.count > 0 {
                myAnnotation = results[0]
            }
        } catch {
            print("error occured:\(error.localizedDescription)")
        }
        return myAnnotation
    }
}




// Mark: This is the API call functionality
// Mark: This is where I build the parameters dictionary that will be used for the API call
extension MapDetailViewController {
    
    // Mark: This function makes the API call
    func getArrayOfPhotos(theLocation:MKAnnotation) {
        // Mark: Builds the parameters for the methodParameters dictionary
        methodParameters = getMethodParametersFromCoordinates(myCoord: theLocation.coordinate)
        // Mark: passes methodParameters and a managedObjectContext to the getPhotos method
        FlickrAPIClient.sharedInstance().getPhotos(params: methodParameters, managedObjectContext: self.getCoreDataStack().context, pin: pin! ) { (success, error, PinImages, globalPages) in
            // Mark: globalPages refers to the number of Pages and there are 18 photos per page.
            if (success)! {
                // Mark: We use the main queue becasue we are useing the managedObjectContext which is created on the main Queue
                DispatchQueue.main.async {
//                    print("Global pages:\(globalPages)")
                    self.totalNumberOfPages = globalPages
                    // Mark: We can get the totalNumberOfPhotos from an API call.
//                    print("totalNumberOfPages:\(self.totalNumberOfPages)")
                    self.disableNewCollectionButtonIfNoPhotos(numberOfPages: self.totalNumberOfPages)
                    // Mark: This if let statement keeps the app from breaking in the case that the API doesn't return any Photo information
                    if let _ = PinImages {
                        for item in PinImages! {
                            item.pinAnnotation = self.pin
                        }
                        self.pinImages = PinImages
                        self.collectionView.reloadData()
                    }
                    

                }
            } else {
                // Mark: This is the functionality that handles the error message if the network request fails. I used some optional binding her as well
                if let myError = error {
                    self.showAlert(messageText: myError)
                } else {
                    self.showAlert(messageText: "There is no error message")
                }
            }
        }
    }
    
    // Mark: API call to retrieve random photos
    func getRandomImagesForPin() {
        let pageLimit = 20
        if let pages = totalNumberOfPages, pages >= pageLimit {
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            FlickrAPIClient.sharedInstance().getPhotosWithRandomPageNumber(methodParameters, randomPage, self.getCoreDataStack().context, completionHandler: { (success, error, PinImages) in
                
                if (success)! {
                    self.pinImages = PinImages
                    self.collectionView.reloadData()
                } else {
                    // Mark: This is the functionality that handles the error message if the network request fails. I used some optional binding her as well
                    if let myError = error {
                        self.showAlert(messageText: myError)
                    } else {
                        self.showAlert(messageText: "There is no error message")
                    }
                }
                
                
            })
            
        }
    }
    
    
    

    // Mark: This method use the coordinats of the current PinAnnotation to create the parameters necessary for the API call.
    private func getMethodParametersFromCoordinates(myCoord:CLLocationCoordinate2D) -> [String:AnyObject] {
        let methodParameters = [
            FlickrAPIClient.Constants.FlickrParameterKeys.APIKey:FlickrAPIClient.Constants.FlickrParameterValues.APIKey,
            FlickrAPIClient.Constants.FlickrParameterKeys.BoundingBox:bboxString(coord: myCoord),
            FlickrAPIClient.Constants.FlickrParameterKeys.Method:FlickrAPIClient.Constants.FlickrParameterValues.SearchMethod,
            FlickrAPIClient.Constants.FlickrParameterKeys.SafeSearch:FlickrAPIClient.Constants.FlickrParameterValues.UseSafeSearch,
            FlickrAPIClient.Constants.FlickrParameterKeys.Extras:FlickrAPIClient.Constants.FlickrParameterValues.MediumURL,
            FlickrAPIClient.Constants.FlickrParameterKeys.NoJSONCallback:FlickrAPIClient.Constants.FlickrParameterValues.DisableJSONCallback,
            FlickrAPIClient.Constants.FlickrParameterKeys.Page:FlickrAPIClient.Constants.FlickrParameterValues.PageValue,
            FlickrAPIClient.Constants.FlickrParameterKeys.Format:FlickrAPIClient.Constants.FlickrParameterValues.ResponseFormat,
            FlickrAPIClient.Constants.FlickrParameterKeys.PerPage:FlickrAPIClient.Constants.FlickrParameterValues.PerPage
            ] as [String : Any]
        
        return methodParameters as [String : AnyObject]
    }
    
    private func bboxString(coord: CLLocationCoordinate2D) -> String {
        // Mark: Functionality that ensures bbox is set by minimum and maximums
        if let latitude = coord.latitude as? Double, let longitude = coord.longitude as? Double {
            
            let minimumLon = max(longitude - FlickrAPIClient.Constants.Flickr.SearchBBoxHalfWidth, FlickrAPIClient.Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrAPIClient.Constants.Flickr.SearchBBoxHalfHeight, FlickrAPIClient.Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrAPIClient.Constants.Flickr.SearchBBoxHalfWidth, FlickrAPIClient.Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrAPIClient.Constants.Flickr.SearchBBoxHalfHeight, FlickrAPIClient.Constants.Flickr.SearchLatRange.1)
            
            //            print("\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)")
            
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }

}


// Mark: The collectionView functionality is here
extension MapDetailViewController {
    
    // Mark: Called from ViewDidLoad
    func collectionViewDelegateAndDataSource() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    // Mark: Set up the flowLayout - called from viewDidLoad
    func flowLayoutSetUp() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        Mark: pinImages array goes here
        let pinImage = pinImages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.imageView.image = nil
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.startAnimating()
            FlickrAPIClient.sharedInstance().getImageData(url: pinImage.url!) { (data, error) in
                
                cell.imageView.image = UIImage(data: data!)
                cell.activityIndicator.startAnimating()
                cell.activityIndicator.isHidden = true
                
            }


        return cell
        
    
    }
    
    // Mark: When the collectionView initially loads
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if let _ = pinImages {
            return pinImages.count
        } else {
            return 0
        }
    }
    
}



// Mark: This is the functionality for setting a pin on the mapView
extension MapDetailViewController {
    
    // Mark: Create a pin and pass the coordinates
    func setAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationAnnotation.coordinate
        annotation.title = ""
        annotation.subtitle = ""
        self.mapView.addAnnotation(annotation)
    }
    
    // Mark: Mapkit also requires that you add a span and region
    func setSpanAndRegion() {
        let latDelta:CLLocationDegrees = 1.00
        let longDelta:CLLocationDegrees = 1.00
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region = MKCoordinateRegion(center: locationAnnotation.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
}

extension MapDetailViewController {
    // Mark: This is the alertController functionality that will be called when an error occurs
    func showAlert(messageText:String) {
        let alert = UIAlertController(title: "", message: "There was an error trying to retrieve the data:" + messageText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss.", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true , completion: nil)
    }
}

