//
//  Complex+CoreDataProperties.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 06.07.2021.
//
//

import Foundation
import CoreData


extension Complex {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Complex> {
        return NSFetchRequest<Complex>(entityName: "Complex")
    }

    @NSManaged public var clId: Int64
    @NSManaged public var clName: String?
    @NSManaged public var id: Int64
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var model: String?
    @NSManaged public var name: String?
    @NSManaged public var placeName: String?
    @NSManaged public var serfiffEndDate: String?
    @NSManaged public var state: Int64
    @NSManaged public var stateName: String?
    @NSManaged public var summaryEfficiency: String?
    @NSManaged public var summaryPassages: String?
    @NSManaged public var summaryResolutions: String?
    @NSManaged public var summaryViolations: String?
    @NSManaged public var typeId: Int64
    @NSManaged public var typeName: String?
    @NSManaged public var unworkReasons: String?
    @NSManaged public var workerDays: Int64
    @NSManaged public var workState: Int64
    @NSManaged public var workTitle: String?

}

extension Complex : Identifiable {

}
