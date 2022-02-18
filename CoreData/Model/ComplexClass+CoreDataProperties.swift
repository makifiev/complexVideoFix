//
//  ComplexClass+CoreDataProperties.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.07.2021.
//
//

import Foundation
import CoreData


extension ComplexClass {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComplexClass> {
        return NSFetchRequest<ComplexClass>(entityName: "ComplexClass")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?

}

extension ComplexClass : Identifiable {

}
