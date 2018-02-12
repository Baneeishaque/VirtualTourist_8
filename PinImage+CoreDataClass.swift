//
//  PinImage+CoreDataClass.swift
//  VirtualTourist_8
//
//  Created by Michelle Grover on 2/11/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import Foundation
import CoreData


public class PinImage: NSManagedObject {
    
    convenience init(title:String?, url:String?, image:NSData?, context:NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "PinImage", in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.url = url
            self.image = image
        
        } else {
             fatalError("Unable to find PinImage entity!!")
        }
    }
}
