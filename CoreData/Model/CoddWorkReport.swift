//
//  CoddWorkReport.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 22.11.2021.
//

import Foundation

class CoddWorkReport : NSObject
{
    var items: AnyObject!
    
    func format(success: @escaping (NSDictionary) -> Void, failure: @escaping (String) -> Void)
    {
        do {
            try tryFormat(success: success, failure: failure)
        } catch
        {
            let reason = "Ошибка формирования отчета!"
            print(failure(reason))
        }
    }
    
    func tryFormat(success: @escaping (NSDictionary) -> Void, failure: @escaping (String) -> Void) throws
    {
        let formattedReport: NSMutableDictionary = [:]
        for item in items as! [NSDictionary]
        {
            let gibddId = Int(item["gibddId"] as? String ?? "0") ?? 0
            
            let violations = Constant.notNilNum(num: item["violation"] as? Int)
            let autoRef = Constant.notNilNum(num: item["autoRef"] as? Int)
            let tsoddRef = Constant.notNilNum(num: item["tsoddRef"] as? Int)
            let tsafapRef =  Constant.notNilNum(num: item["tsafapRef"] as? Int)
            
            var ordinance = 0
            var key: String = ""
            var dict: NSDictionary!
            
            if gibddId == 0
            {
                ordinance = Constant.notNilNum(num: item["ordinance"] as? Int)
                key = "ВСЕГО"
                
                dict = ["in" : violations,
                        "out" : [["внешние системы" : autoRef],
                                 ["предобработка" : tsoddRef],
                                 ["оформление" : tsafapRef]],
                        "result" : ordinance]
            }
            else if gibddId % 1000 == 519
            {
                ordinance = Constant.notNilNum(num: (item["gibddOrds"] as! NSDictionary)["3"] as? Int)
                key = "ЦАФАП"
                dict = ["in" : violations,
                        "out" : [["внешние системы" : autoRef],
                                 ["ЦОДД" : tsoddRef],
                                 ["ЦАФАП" : tsafapRef]],
                        "result" : ordinance]
            }
            else if gibddId % 1000 == 592
            {
                ordinance = Constant.notNilNum(num: (item["gibddOrds"] as! NSDictionary)["4"] as? Int)
                key = "АМПП"
                
                dict = ["in" : violations,
                        "out" : [["внешние системы" : autoRef],
                                 ["ЦОДД" : tsoddRef],
                                 ["АМПП" : tsafapRef]],
                        "result" :  ordinance]
            }
            else if gibddId % 1000 == 597
            {
                ordinance = Constant.notNilNum(num: (item["gibddOrds"] as! NSDictionary)["5"] as? Int)
                key = "МАДИ"
                
                dict = ["in" : violations,
                        "out" : [["внешние системы" : autoRef],
                                 ["ЦОДД" : tsoddRef],
                                 ["МАДИ" : tsafapRef]],
                        "result" : ordinance]
            }
            if key.count != 0
            {
                formattedReport.setObject(dict!, forKey: key as NSCopying)
            }
        }
        
        DispatchQueue.main.async {
            
            if success != nil
            {
                success(formattedReport)
            }
        }
    }
}
