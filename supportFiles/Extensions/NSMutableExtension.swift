//
//  NSMutableExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 31.08.2021.
//

import Foundation


extension NSMutableArray
{
    func sort(ascending: Bool)
    {
        let sortDescriptor = NSSortDescriptor(key: "self", ascending: ascending)
        self.sort(using: [sortDescriptor])
    }
    
    func getCountValues(arrays: NSArray) -> NSArray
    {
        let array1 = arrays[0] as! NSArray
        let aaray2 = arrays[1] as! NSArray
        
        let values:NSMutableArray = []
        for i in 0..<array1.count
        {
            values.add(0)
        }
        for item:Any in aaray2
        {

            let index = (array1 as! [Int]).firstIndex(where: {$0 == item as! Int})
            if index != nil
            {
                let value = values[index!] as! Int
                values[index!] = value + 1
            }
        }
        return values
    }
}
