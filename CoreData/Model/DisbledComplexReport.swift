//
//  DisbledComplexReport.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 26.10.2021.
//

import Foundation
import UIKit
import CoreData


extension NSMutableDictionary
{
    func addObject(object: AnyObject, forKey: String)
    {
        var array = self[forKey] as? NSMutableArray
        if array == nil
        {
            array = [] as NSMutableArray
        }
        array!.add(object)
        self.setObject(array!, forKey: forKey as NSCopying)
    }
}

extension NSArray
{
    func getCameras(array: NSMutableArray) -> NSArray
    {
        let cameras = [] as NSMutableArray
        for cameraId in array
        {
            if self.contains(cameraId)
            {
                cameras.add(cameraId)
            }
        }
        return cameras
    }
}

class DisabledComplexReport: NSObject
{
    var mDiffMinus: NSMutableArray!
    var mDiffPlus: NSMutableArray!
    var mClass: String!
    var mCameraDicts: NSMutableDictionary!
    var mCameras: NSMutableDictionary!
    
    var mFormattedReport: NSMutableArray!
    var day1 = [NSDictionary]()
    var day2 = [NSDictionary]()
    
    func formatThrow(success: @escaping(NSArray) -> Void) throws
    {
        mFormattedReport = [] as NSMutableArray
        
        mDiffPlus = [] as NSMutableArray
        for dict: NSDictionary in self.day1
        {
            let cameraId = Constant.notNilNum(num: dict["cameraId"] as? Int)
            if !mDiffPlus.contains(cameraId)
            {
                mDiffPlus.add(cameraId)
            }
        }
        
        mDiffMinus = [] as NSMutableArray
        
        for dict: NSDictionary in self.day2
        {
            let cameraId = Constant.notNilNum(num: dict["cameraId"] as? Int)
            if !mDiffMinus.contains(cameraId)
            {
                mDiffMinus.add(cameraId)
            }
        }
        
        
        
        var diffMinus: [Any] = []
        diffMinus.append(contentsOf: mDiffMinus as! [Any])
        mDiffMinus.removeObjects(in: mDiffPlus as! [Any])
        mDiffPlus.removeObjects(in: diffMinus)
        
        mCameraDicts = [:] as NSMutableDictionary
        let ids = [] as NSMutableSet
        for dict in self.day1
        {
            let id = Constant.notNilNum(num: dict["cameraId"] as? Int)
            if !ids.contains(id)
            {
                mCameraDicts.setObject(dict, forKey: id as NSCopying)
                ids.add(id)
            }
        }
        for dict in self.day2
        {
            let id = Constant.notNilNum(num: dict["cameraId"] as? Int)
            if !ids.contains(id)
            {
                mCameraDicts.setObject(dict, forKey: id as NSCopying)
                ids.add(id)
            }
        }
        
        let cameras = CoreDataStack.sharedInstance.getCamerasSortedByTypeAndClassInIds(ids: ids.allObjects as NSArray)
        for i in 0..<(cameras.sections?.count ?? 0)
        {
            let section = cameras.sections?[i]
            if section?.numberOfObjects != 0
            {
                let type = section!.name.uppercased()
//                let endIndex = type.index(type.endIndex, offsetBy: -2)
//                type.replaceSubrange(...endIndex, with: "ЫЕ")
                mFormattedReport.add(type)
                
                mClass = ""
                mCameras = [:] as NSMutableDictionary
                for j in 0..<section!.numberOfObjects
                {
                    let camera = cameras.object(at: IndexPath(row: j, section: i)) as! Camera
                    if j != 0 && mClass != camera.clName
                    {
                        self.addReportRow()
                    }
                    if j == section!.numberOfObjects - 1
                    {
                        self.addCamera(camera:camera)
                        self.addReportRow()
                    }
                    else
                    {
                        self.addCamera(camera:camera)
                    }
                }
            }
        }
        DispatchQueue.main.async {
                success(self.mFormattedReport)
        }
    }
    
    func format(success: @escaping(NSArray) -> Void, failure: @escaping(String) -> Void)
    {
        DispatchQueue.global(qos: .background).async
        { [self] in
            do
            {
                try formatThrow(success: success)
            }
            catch
            {
                let reason = "Ошибка формирования отчета!"
                DispatchQueue.main.async {
                        failure(reason)
                }
            }
        }
    }
    
    func addCamera(camera: Camera)
    {
        mClass = camera.clName
        mCameras.setObject(camera, forKey: camera.id as NSCopying)
    }
    
    func addReportRow()
    {
        var disabledCameras = NSMutableDictionary() as AnyObject
        var limitedWorkCameras = NSMutableDictionary()  as AnyObject
        
        for id in mCameras.allKeys
        {
            let id = id as! Int
            let dict = mCameraDicts[id] as? NSDictionary
            if dict != nil
            { 
                let cameras = ((dict!["workFlag"] as? Int) == 0 ? disabledCameras as! NSMutableDictionary : limitedWorkCameras as! NSMutableDictionary)
                cameras.addObject(object: id as AnyObject, forKey: "all")
                
                let name = dict!["name"] as? String
                if name?.count != 0
                {
                    cameras.addObject(object: id as AnyObject, forKey: name!)
                }
            }
        }
        var plus = [] as NSArray
        var minus = [] as NSArray
        
        let disabledCameraCategories = [] as NSMutableArray
        for key in disabledCameras.allKeys
        {
            let key = key as! String
            let array = disabledCameras[key] as! NSMutableArray
            if key != "all"
            {
                plus = array.getCameras(array: mDiffPlus)
                minus = array.getCameras(array: mDiffMinus)
                 
                array.removeObjects(in: minus as! [Any])
                disabledCameraCategories.add([key,
                                              array.count,
                                              plus.count,
                                              minus.count,
                                              ["Список КВФ":Constant.notNil(obj: array),
                                               "-": Constant.notNil(obj: plus),
                                               "+": Constant.notNil(obj: minus)],
                                              []])
            }
        }
        plus = (disabledCameras["all"] as? NSArray ?? []).getCameras(array: mDiffPlus)
        minus = (disabledCameras["all"] as? NSArray ?? []).getCameras(array: mDiffMinus)
        
        var array = disabledCameras["all"] as? NSMutableArray ?? []

        array.removeObjects(in: minus as! [Any])
        
        disabledCameras = ["не работают",
                                    array.count,
                           minus.count,
                           plus.count,
                                    ["Список КВФ" : Constant.notNil(obj: array), "-" : Constant.notNil(obj: plus), "+" : Constant.notNil(obj: minus)],
                                    disabledCameraCategories] as NSMutableArray
        
        let limitedWorkCameraCategories = [] as NSMutableArray
        for key in limitedWorkCameras.allKeys
        {
            let array = limitedWorkCameras[key] as? NSMutableArray ?? []
            let key = key as! String
            if key != "all"
            {
                plus = array.getCameras(array: mDiffPlus)
                minus = array.getCameras(array: mDiffMinus)
                
                 
                array.removeObjects(in: minus as! [Any])
                limitedWorkCameraCategories.add([key,
                                                 array.count,
                                                 minus.count,
                                                  plus.count,
                                                 ["Список КВФ": Constant.notNil(obj: array),
                                                  "-" : Constant.notNil(obj: plus),
                                                  "+" : Constant.notNil(obj: minus )],
                                                 []])
            }
        }
        
        plus = (limitedWorkCameras["all"] as? NSArray ?? []).getCameras(array: mDiffPlus)
        minus = (limitedWorkCameras["all"] as? NSArray ?? []).getCameras(array: mDiffMinus)
        
        array = limitedWorkCameras["all"] as? NSMutableArray ?? []
        array.removeObjects(in: minus as! [Any])
        
        limitedWorkCameras = ["работают с ограничениями",
                                       array.count,
                                        minus.count,
                                        plus.count,
                                       ["Список КВФ" : Constant.notNil(obj: array),
                                        "-" : Constant.notNil(obj: plus),
                                        "+" : Constant.notNil(obj: minus)],
                                       limitedWorkCameraCategories] as NSMutableArray
        
        plus = (mCameras.allKeys as NSArray).getCameras(array: mDiffPlus)
        minus = (mCameras.allKeys as NSArray).getCameras(array: mDiffMinus)
         
        mCameras.removeObjects(forKeys: minus as! [Any])
        
        mFormattedReport.add([mClass!,
                              mCameras.count,
                              minus .count,
                              plus.count,
                              ["Список КВФ": Constant.notNil(obj: mCameras.allKeys as AnyObject),
                               "-" : Constant.notNil(obj: plus),
                               "+" : Constant.notNil(obj: minus)],
                              [disabledCameras,
                               limitedWorkCameras]])
        
        mCameras.removeAllObjects()
    }
}
