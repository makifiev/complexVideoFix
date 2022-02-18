//
//  ComplexType+CoreDataProperties.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.07.2021.
//
//

import Foundation
import CoreData


extension ComplexType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComplexType> {
        return NSFetchRequest<ComplexType>(entityName: "ComplexType")
    }

    @NSManaged public var acronym: String?
    @NSManaged public var id: Int64
    @NSManaged public var mobilityType: Int64
    @NSManaged public var name: String?

}

extension ComplexType : Identifiable {

}
