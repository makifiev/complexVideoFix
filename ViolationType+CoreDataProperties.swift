//
//  ViolationType+CoreDataProperties.swift
//  
//
//  Created by Акифьев Максим  on 02.12.2021.
//
//

import Foundation
import CoreData


extension ViolationType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ViolationType> {
        return NSFetchRequest<ViolationType>(entityName: "ViolationType")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var type: String?

}
