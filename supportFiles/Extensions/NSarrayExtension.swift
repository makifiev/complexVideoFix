//
//  NSarray.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 13.07.2021.
//

import Foundation
import UIKit

extension NSArray
{
    func get(val: String) -> Any
    {
        var object: Any? = self.value(forKey: val)
        
        if object is String
        {
            var string:String! = object as? String
            if (string.count != 0)
            {
                object = nil
            }
        }
        return object is NSNull ? nil : object
    }
}

