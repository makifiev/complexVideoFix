//
//  Constants.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 08.07.2021.
//

import Foundation
import UIKit
import GoogleMaps

class Constant: UIView
{
    
    static let any = -1
    static let blanc = -2
    static let workLimited = 0
    static let work = 1
    static let noWork = 2
    static let noWorkWithReason = 3
    
    static let dummy = 10
    static let draft = 1
    static let archive = 5
    static let workTitle: [String:String] = ["\(Constant.any)":"Любая", "\(Constant.blanc)":"", "\(Constant.workLimited)":"Работает с ограничениями", "\(Constant.work)":"Работает без ограничений", "\(Constant.noWork)":"Не работает по неизвестной причине", "\(Constant.noWorkWithReason)":"Не работает по причине"]
    static let workStates = [work, workLimited, noWork, noWorkWithReason] as NSMutableArray
    static let GoogleMapApiKey = "AIzaSyBtX43uxIdUSHTW6zld1JDptPh2QZJ9iVY"
    static let moscowCoordiantes = CLLocationCoordinate2D(latitude: 55.741801, longitude: 37.612381)
    
    
    static var iOS11IsAvailable = { () -> Bool in 
        if #available(iOS 11.0, *)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    static func systemVersionGreaterThan(v: String) -> Bool
    {
        return UIDevice.current.systemVersion.compare(v, options: NSString.CompareOptions.numeric)  == ComparisonResult.orderedDescending
    }
    static let IOS7 = systemVersionGreaterThan(v: "6.9")
    static let IOS8 = systemVersionGreaterThan(v: "7.9")
    static let IOS9 = systemVersionGreaterThan(v: "8.9")
    static let IOS10 = systemVersionGreaterThan(v: "9.9")
    static let IOS11 = systemVersionGreaterThan(v: "10.9")
    static let IOS12 = systemVersionGreaterThan(v: "11.9")
    static let IOS13 = systemVersionGreaterThan(v: "12.9")
    
    static let mainFrame = IPAD ? IpadMainViewFrame : mainFrameNormal
    static let IpadMainViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    static let mainFrameNormal = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    static let IPAD = UIDevice.current.userInterfaceIdiom.rawValue == 1
    static let iPhoneX = mainFrame.size.height > 800
    static let iPhone6Plus =  mainFrame.size.width > 375
    static let iphone6 = mainFrame.size.width > 320
    static let iPhoneNavBarCoefficient = iPhoneX ? 24 : 0
    static let iPhoneXTabBarCoefficient = iPhoneX ? 10 : 0
    static let statusBarHeightCurrent = UIApplication.shared.statusBarUIView!.frame.size.height
    static let statusBarHeight = (!iPhoneX && statusBarHeightCurrent > 20) ? statusBarHeightCurrent / 2 : statusBarHeightCurrent
    static let BlurTag = 10000
    static let tabBarHeight = TabBarViewController.tabBarHeight
    
    static let topBarHeight = statusBarHeight + TabBarViewController.navigationBarHeight
    
    static let tabBarHeightConstant = 49
    static let complexPanelOffset = iPhone6Plus ? 230 : (iphone6 ? 200 : 150)
    static func navigationBarHeight(navigationController : UINavigationController) -> CGFloat
    {
        return navigationController.navigationBar.size.height
    }
    
    static func setFontBold( size: CGFloat) -> UIFont
    {
        let FontBold = UIFont(name:"HelveticaNeue-Bold", size: size)!
        return FontBold
    }
    
    static func setMediumFont( size: CGFloat) -> UIFont
    {
        let fontMedium = UIFont(name:"HelveticaNeue-Medium", size: size)!
        return fontMedium
    }
    static func notNilNum(num: Int?) -> Int
    {
        let res = 0
        if num == nil
        {
            return res
        }
        else
        {
            return num!
        }
    }
    static func notNilStr(str: String?) -> String
    {
        let res = ""
        if str == nil
        {
            return res
        }
        else
        {
            return str!
        }
    }
    
    static func degreesToRadians(degrees: Double) -> Double
    {
        return degrees * (Double.pi / 180)
    }
    
    static func radiansToDegrees (radians: Double) -> Double
    {
        return radians * (180 / Double.pi)
    }
    
    static let colors = [any: UIColor.Gray,
                         blanc: UIColor.clear,
                         workLimited: UIColor.Orange,
                         work: UIColor.Green,
                         noWork: UIColor.Red,
                         noWorkWithReason: UIColor.Purple,
                         dummy: UIColor.mediumDarkGray]
    
    static let colorsAlpha = [any: UIColor.GrayApha,
                              blanc: UIColor.clear,
                              workLimited: UIColor.OrangeAlpha,
                              work: UIColor.GreenAlpha,
                              noWork: UIColor.RedAlpha,
                              noWorkWithReason: UIColor.PurpleAlpha]
    static let workTitles = [any: "Любая",
                             blanc: "",
                             workLimited: "Работает с ограничениями",
                             work:"Работает без ограничений",
                             noWork: "Не работает по неизвестной причине",
                             noWorkWithReason:"Не работает по причине"]
    
    
    static let searchEnabled = "SearchEnabled"
    static let mapType = "MapType"
    static let dataBaseUpdated = "DatabaseUpdated"
    static let dataBaseCreated = "DatabaseCreated"
    static let showTabBarButtons = "showTabBarButtons"
    static let registered = "Registered"
    static let historyReady = "HistoryReady"
    static let latitudeAccuracyCoefficient = 0.0001
    static let longitudeAccuracyCoefficient = 0.0001
    
    static let panoramaType = "PanoramaType"
    static func getYandexPanoramaURL(latitude: Double, longitude: Double, bearing:Double) -> String
    {
        //        let returnString = "<!DOCTYPE html> <html lang='ru'> <head> <style> html, body, .player { width: 100%%; height: 100%%; margin: 0; padding: 0; } </style> <script src='https://api-maps.yandex.ru/2.1/?lang=ru_RU&amp;load=package.full'></script> <script> ymaps.ready(function () { if (!ymaps.panorama.isSupported()) { return; } ymaps.panorama.createPlayer('player1', [\(latitude), \(longitude)], {controls: ['panoramaName'], direction: [\(bearing), 0]}) .done(function (player) { }); }); </script> </head> <body> <div id='player1' class='player'></div> </body> </html>"
        
        let returnString = "https://yandex.ru/maps/213/moscow/?l=stv%2Csta&ll=\(latitude)%2C\(longitude)&panorama%5Bdirection%5D=\(bearing)%2C0.000000&panorama%5Bfull%5D=true&panorama%5Bpoint%5D=\(latitude)%2C\(longitude)&panorama%5Bspan%5D=\(latitude)%2C\(longitude)&z=15"
        //        https://yandex.ru/maps/?panorama[point]=\(latitude),\(longitude)&panorama[direction]=\(bearing),6.060547&panorama[span]=130.000000,71.919192"
        //        let returnString =  "https://yandex.ru/maps/213/moscow/?l=stv%2Csta&ll=\(latitude)%\(longitude)&panorama%5Bdirection%5D=\(bearing)%2C0.000000&panorama%5Bfull%5D=true&panorama%5Bpoint%5D=37.768527%2C55.860383&panorama%5Bspan%5D=92.002906%2C60.000000&z=10"
        return returnString
        
        
    }
    static func touch3D(controller: UIViewController) -> Bool
    {
        if controller.traitCollection.forceTouchCapability == .available
        {
            return true
        }
        else
        {
            return false
        }
    }
    static func notNil(obj: AnyObject?) -> AnyObject
    {
        if obj == nil
        {
            return "Нет Данных" as AnyObject
        }
        else
        {
            return obj!
        }
    }
}

