//
//  Camera+CoreDataProperties.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 08.07.2021.
//
//

import Foundation
import CoreData


extension Camera {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Camera> {
        return NSFetchRequest<Camera>(entityName: "Camera")
    }

    @NSManaged public var azimuth: Int64
    @NSManaged public var clName: String?
    @NSManaged public var complexId: Int64
    @NSManaged public var directionId: Int64
    @NSManaged public var directionName: String?
    @NSManaged public var externalId: String?
    @NSManaged public var id: Int64
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var name: String?
    @NSManaged public var placeName: String?
    @NSManaged public var purposeTypeId: Int64
    @NSManaged public var purposeTypeName: String?
    @NSManaged public var stateId: Int64
    @NSManaged public var stateName: String?
    @NSManaged public var summaryEfficiency: String?
    @NSManaged public var summaryPassages: String?
    @NSManaged public var summaryResolutions: String?
    @NSManaged public var summaryViolations: String?
    @NSManaged public var tsafap: Int64
    @NSManaged public var typeName: String?
    @NSManaged public var unworkReasons: String?
    @NSManaged public var workerDays: Int64
    @NSManaged public var workerId: Int64
    @NSManaged public var workerName: String?
    @NSManaged public var workFlag: Int64
    @NSManaged public var workState: Int64
    @NSManaged public var workTitle: String?

}

extension Camera : Identifiable {

}
