//
//  MapViewController.swift
//  VirtualTourist_8
//
//  Created by Michelle Grover on 2/10/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapButtonOutlet: UIBarButtonItem!
    
    // Mark: Functionality pertaining to the bottom button and its ability to show or hide
    var button1:UIButton!
    var bottomButtonConstraint: NSLayoutConstraint!
    
    // Mark: This is the boolean value that dictates when you can add annotation or remove annotations
    var buttonOn:Bool = false
    
    // Mark: CoreData variables
    let delegate = UIApplication.shared.delegate as! AppDelegate
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mark: Setting mapView delegate
        self.mapView.delegate = self
        
        // Mark: Prepare the bottom button to show or hide
        prepareShowButton()
        
        
        // Mark: Set the gesture recognizer for the mapView
        gestureRecognizerFunctionality()
        
        // Mark: Load annotations from CoreData
        self.loadAnnotations()
        
    }
    
    // Mark: This is where the editButton functionality is located
    @IBAction func editButtonPressed(_ sender: Any) {
        buttonOn ? hideButton() : showButton()
        buttonOn = !buttonOn
    }
}

// Mark: This is where the CoreData functionality is located
extension MapViewController {
    
    // Mark: This loads all of the PinAnnotation Data out of CoreData and onto the mapView
    func loadAnnotations() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]
        
        do {
            let results = try getCoreDataStack().context.fetch(fetchRequest) as! [PinAnnotation]
            for result in results {
                let annotation = MKPointAnnotation()
                annotation.title = "Title"
                annotation.subtitle = "Subtitle"
                annotation.coordinate.latitude = result.lat
                annotation.coordinate.longitude = result.long
                self.mapView.addAnnotation(annotation)
            }
        } catch {
            print("error occured:\(error.localizedDescription)")
        }
    }
    
    // Mark: This function will retrieve the CoreDataStack. From here you can access the context
    func getCoreDataStack() -> CoreDataStack {
        let stack = delegate.stack
        return stack
    }
    
    // Mark: Add annotation to CoreData as PinAnnotation
    func addPinAnnotationToCoreData(_ annotation:MKPointAnnotation) -> Bool {
        
        let _ = PinAnnotation(lat: annotation.coordinate.latitude, long: annotation.coordinate.longitude, context: getCoreDataStack().context)
        
        do {
            try getCoreDataStack().saveContext()
            return true
        } catch {
            print("Error saving PinAnnotation:\(error.localizedDescription)")
            return false
        }
    }
    
    
    // Mark: Deletes PinAnnotation from CoreData
    func deleteAnnotationFromCoreData(_ annotation:MKAnnotation) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]
        let pred = NSPredicate(format: "lat = %lf AND long = %lf", annotation.coordinate.latitude, annotation.coordinate.longitude)
        fetchRequest.predicate = pred
        
        do {
            let results = try getCoreDataStack().context.fetch(fetchRequest)
            for result in results {
                getCoreDataStack().context.delete(result as! NSManagedObject)
            }
            do {
                try getCoreDataStack().saveContext()
            } catch let e as NSError {
                print("There was an error saving the delete information:\(e.localizedDescription)")
            }
            return true
        } catch {
            print("There was an error when attempting to delete annotation:\(error.localizedDescription)")
            return false
        }
    }
    
}


// Mark: This is where the mapView annotation functionality is located
extension MapViewController {

    // Mark: This is the gesture recognizer that recognizes the long press
    func gestureRecognizerFunctionality() {
        let mapPressed = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        mapPressed.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(mapPressed)
    }
    
    // Mark: This is a function leveraged from the MKMapViewDelegate. This animates the pinDrop and hides the callout
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            // Setting this to false prevents the pin from creating a clickable tab
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        pinView?.animatesDrop = true
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if let locationAnnotation = view.annotation {
            if (!buttonOn) {
                // Mark: The buttonOn = false so clicking the pinAnnotation sends you to the detailView.
                self.moveToDetailView(locationAnnotation)
            } else {
                // Mark: Remove the PinAnnotation from the mapView
                if (deleteAnnotationFromCoreData(locationAnnotation)) {
                    self.mapView.removeAnnotation(locationAnnotation)
                }
            }
        }
    }
    
    // Mark: This function sets the value of locationAnnotation property for MapDetailViewController
    func moveToDetailView(_ location:MKAnnotation) {
        let mapViewDetailController = self.storyboard?.instantiateViewController(withIdentifier: "MapDetailViewController") as! MapDetailViewController
        mapViewDetailController.locationAnnotation = location
        navigationController?.pushViewController(mapViewDetailController, animated: true)
    }
    
    
    // Mark: Adds the PinAnnotation to the mapView and CoreData
    func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Title"
            annotation.subtitle = "Subtitle"
            
            if (!buttonOn) {
                if (self.addPinAnnotationToCoreData(annotation)) {
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    

}


// Mark: This function programmatically creates the RED button at the bottom of the page and animates its dissappearance and appearance on screen
extension MapViewController {
    
    
    func prepareShowButton() {
        
        button1 = UIButton(type: .system)
        button1.setTitle("Tap Pins to Delete", for: .normal)
        button1.backgroundColor = UIColor.red
        button1.tintColor = UIColor.white
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        view.addSubview(button1)
        
        button1.translatesAutoresizingMaskIntoConstraints = false
        
        let leftButtonEdgeConstraint = NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0)
        let rightButtonEdgeConstraint = NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0)
        bottomButtonConstraint = NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 80)
        
        let heightConstraint = NSLayoutConstraint(item: button1, attribute: .height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80)
        
        view.addConstraints([leftButtonEdgeConstraint, rightButtonEdgeConstraint, bottomButtonConstraint, heightConstraint])
        
    }
    
    // MARK: - Functionality to Show Bottom Button
    func showButton() {
        mapButtonOutlet.title = editButtonTitle(buttonOn)
        UIView.animate(withDuration: 0.5) {
            self.bottomButtonConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Functionality to Hide Bottom Button
    func hideButton() {
        mapButtonOutlet.title = editButtonTitle(buttonOn)
        UIView.animate(withDuration: 0.5) {
            self.bottomButtonConstraint.constant = 80
            self.view.layoutIfNeeded()
        }
    }
    // Mark: Sets the title for the editButton on the navigation bar
    func editButtonTitle(_ isButtonOn:Bool) -> String {
//        print("\(isButtonOn ? "Edit" : "Done")")
        return isButtonOn ? "Edit" : "Done"
    }
    
}
