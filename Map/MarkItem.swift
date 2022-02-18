//
//  MarkItem.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.08.2021.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils

class MarkerItem: NSObject, GMUClusterItem
{
    var position: CLLocationCoordinate2D
    var userData: AnyObject!
    
    init(position: CLLocationCoordinate2D, userData: AnyObject!)
    { 
        self.position = position
        self.userData = userData! 
        super.init()
    }
    
}
