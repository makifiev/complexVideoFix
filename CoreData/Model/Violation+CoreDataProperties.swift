//
//  Violation+CoreDataProperties.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 13.07.2021.
//
//

import Foundation
import CoreData


extension Violation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Violation> {
        return NSFetchRequest<Violation>(entityName: "Violation")
    }

    @NSManaged public var cameraId: Int64
    @NSManaged public var complexId: Int64
    @NSManaged public var directionId: Int64
    @NSManaged public var directionName: String?
    @NSManaged public var id: Int64
    @NSManaged public var limitStr: String?
    @NSManaged public var parentId: String?
    @NSManaged public var state: Int64
    @NSManaged public var stateName: String?
    @NSManaged public var statePriority: String?
    @NSManaged public var violExcessLevel: Int64
    @NSManaged public var violId: Int64
    @NSManaged public var violLimitId: Int64
    @NSManaged public var violName: String?
    @NSManaged public var violValueLimit: Int64
    @NSManaged public var violValueUnit: String?
    @NSManaged public var zoneId: Int64
    @NSManaged public var zoneName: String?

}

extension Violation : Identifiable {

}
