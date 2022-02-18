//
//  Dummy+CoreDataProperties.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.07.2021.
//
//

import Foundation
import CoreData


extension Dummy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dummy> {
        return NSFetchRequest<Dummy>(entityName: "Dummy")
    }

    @NSManaged public var azimuth: Int64
    @NSManaged public var clId: Int64
    @NSManaged public var clName: String?
    @NSManaged public var id: Int64
    @NSManaged public var inventoryNumber: String?
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var placeName: String?
    @NSManaged public var serialNumber: String?
    @NSManaged public var stateId: Int64
    @NSManaged public var stateName: String?
    @NSManaged public var typeId: Int64
    @NSManaged public var typeName: String?

}

extension Dummy : Identifiable {

}
