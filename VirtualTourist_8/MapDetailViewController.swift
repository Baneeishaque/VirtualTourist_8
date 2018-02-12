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

class MapDetailViewController: UIViewController {
    
    var locationAnnotation:MKAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Test annotation:lat:\(String(describing: locationAnnotation?.coordinate.latitude)), long:\(String(describing: locationAnnotation?.coordinate.longitude))")
    }

    


}

