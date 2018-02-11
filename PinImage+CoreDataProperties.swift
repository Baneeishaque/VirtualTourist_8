//
//  PinImage+CoreDataProperties.swift
//  VirtualTourist_8
//
//  Created by Michelle Grover on 2/11/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import Foundation
import CoreData


extension PinImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PinImage> {
        return NSFetchRequest<PinImage>(entityName: "PinImage")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var pinAnnotation: PinAnnotation?

}
