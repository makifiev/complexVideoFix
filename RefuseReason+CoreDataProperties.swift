//
//  RefuseReason+CoreDataProperties.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.07.2021.
//
//

import Foundation
import CoreData


extension RefuseReason {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RefuseReason> {
        return NSFetchRequest<RefuseReason>(entityName: "RefuseReason")
    }

    @NSManaged public var id: Int64
    @NSManaged public var reason: String?

}

extension RefuseReason : Identifiable {

}
