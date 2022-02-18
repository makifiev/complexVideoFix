//
//  ComplexStatusReport.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 23.11.2021.
//

import Foundation

class ComplexStatusReport: NSObject
{
    var day1 : Array<Any>!
    var day2 : Array<Any>!
    
    func format(success: @escaping () -> Void, failure: @escaping (String) -> Void)
    {
        do {
            try tryFormat(success: success, failure: failure)
        } catch  {
            let reason = "Ошибка формирования отчета!"
            failure(reason)
        }
    }
    
    func tryFormat(success: @escaping () -> Void, failure: @escaping (String) -> Void) throws
    {
        if self.day1.count != self.day2.count
        {
            let count = max(self.day1.count, self.day2.count)
            let day1More = self.day1.count > self.day2.count
            
            for i in 0..<count
            {
                let day1Name = (self.day1.count - 1 >= i) ? ((self.day1[i] as! NSDictionary)["name"]) as! String: ""
                let day2Name = (self.day2.count - 1 >= i) ? ((self.day2[i] as! NSDictionary)["name"]) as! String: ""
                
                if day1Name != day2Name
                {
                    if day1More
                    {
                        self.day2.insert(["name" : day1Name, "camCnt" : 0, "pasCnt" : 0], at: i)
                    }
                    else
                    {
                        self.day1.insert(["name" : day2Name, "camCnt" : 0, "pasCnt" : 0], at: i)
                    }
                }
            }
        }
        
        self.getSum()
        
        DispatchQueue.main.async
        {
            success()
        }
    }
    
    func getSum()
    {
        var days = [self.day1!, self.day2!]
        for i in 0..<days.count
        {
            let array1 : Array<Any> = days[i]
                
            var camCnt = 0
            var pasCnt = 0
            for dict in array1
            {
                let dict = dict as! NSArray
                
                for dict in dict
                {
                let dict = dict as? NSDictionary ?? [:]
                camCnt += dict["camCnt"] as? Int ?? 0
                pasCnt += dict["pasCnt"] as? Int ?? 0
                }
            }
//            array1.removeAllObjects()
            var test = array1[0] as! Array<Any>
            test.insert((["name" : "Всего", "camCnt" : camCnt, "pasCnt" : pasCnt] as! Any), at: 0)
//            array1.insert(["name" : "Всего", "camCnt" : camCnt, "pasCnt" : pasCnt], at: 0)
            
            days[i] = test  
        }
        
        self.day1 = days[0]
        self.day2 = days[1]
    }
}
