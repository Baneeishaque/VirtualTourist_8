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

class MapDetailViewController: UIViewController, MKMapViewDelegate {
    
    var locationAnnotation:MKAnnotation!
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mark: Set the mapView delegate
        mapView.delegate = self
        setSpanAndRegion()
        setAnnotation()
       
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

