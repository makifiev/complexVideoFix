//
//  DisableReason+CoreDataProperties.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.07.2021.
//
//

import Foundation
import CoreData


extension DisableReason {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DisableReason> {
        return NSFetchRequest<DisableReason>(entityName: "DisableReason")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?

}

extension DisableReason : Identifiable {

}
