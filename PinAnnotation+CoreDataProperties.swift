//
//  PinAnnotation+CoreDataProperties.swift
//  VirtualTourist_8
//
//  Created by Michelle Grover on 2/11/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import Foundation
import CoreData


extension PinAnnotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PinAnnotation> {
        return NSFetchRequest<PinAnnotation>(entityName: "PinAnnotation")
    }

    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var pinImages: NSSet?

}

// MARK: Generated accessors for pinImages
extension PinAnnotation {

    @objc(addPinImagesObject:)
    @NSManaged public func addToPinImages(_ value: PinImage)

    @objc(removePinImagesObject:)
    @NSManaged public func removeFromPinImages(_ value: PinImage)

    @objc(addPinImages:)
    @NSManaged public func addToPinImages(_ values: NSSet)

    @objc(removePinImages:)
    @NSManaged public func removeFromPinImages(_ values: NSSet)

}
