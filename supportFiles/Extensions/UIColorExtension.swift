//
//  UIColorExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 03.08.2021.
//

import Foundation
import UIKit

extension UIColor
{
    class var blueBackground: UIColor
    {
        return self.init(red: 121/255.0, green: 158/255.0, blue: 204/255.0, alpha: 1.0)
    }
    class var darkBlueBackground: UIColor
    {
        return self.init(red: 89/255.0, green: 122/255.0, blue: 163/255.0, alpha: 1.0)
    }
    
    class var lightOrangeAuth: UIColor
    {
        return self.init(red: 253/255.0, green: 159/255.0, blue: 59/255.0, alpha: 1.0)
    }
    
    class var orangeAuth: UIColor
    {
        return self.init(red: 253/255.0, green: 132/255.0, blue: 20/255.0, alpha: 1.0)
    }
    
    static let DarkGray = UIColor.rgb(red: 73, green: 73, blue: 73, alpha: 1)
    
    static let DarkGrayAlpha = UIColor.rgb(red: 83, green: 83, blue: 83, alpha: 0.6)
    
    static let mediumDarkGray = UIColor.rgb(red: 118, green: 118, blue: 118, alpha: 1)
    
    static let Gray = UIColor.rgb(red: 194, green: 194, blue: 194, alpha: 1)
    static let GrayApha =  UIColor.rgb(red: 194, green: 194, blue: 194, alpha: 0.6)
    
    static let MediumGray = UIColor.rgb(red: 140, green: 140, blue: 140, alpha: 1)
    static let MediumGrayApha =  UIColor.rgb(red: 140, green: 140, blue: 140, alpha: 0.6)
    
    static let MediumGray2 = UIColor.rgb(red: 160, green: 160, blue: 160, alpha: 1)
    static let MediumGrayApha2 =  UIColor.rgb(red: 160, green: 160, blue: 160, alpha: 0.6)
    
    static let Orange = UIColor.rgb(red: 253, green: 137, blue: 9, alpha: 1)
    
    static let OrangeAlpha = UIColor.rgb(red: 253, green: 137, blue: 9, alpha: 0.6)
    
    static let Green = UIColor.rgb(red: 22, green: 168, blue: 87, alpha: 1)
    static let GreenAlpha = UIColor.rgb(red: 22, green: 168, blue: 87, alpha: 0.6)
    
    static let Red =  UIColor.rgb(red: 251, green: 20, blue: 68, alpha: 1)
    static let RedAlpha =  UIColor.rgb(red: 251, green: 20, blue: 68, alpha: 0.6)
    
    static let Purple = UIColor.rgb(red: 147, green: 42, blue: 213, alpha: 1)
    static let PurpleAlpha = UIColor.rgb(red: 147, green: 42, blue: 213, alpha: 0.6)
    
    static let White = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 1)
    static let WhiteAlpha = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0.6)
    static let WhiteUltraAlpha = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0.3)
    static let WhiteWeakAlpha = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0.9)
    
    static let BlackAlpha = UIColor.rgb(red: 0, green: 0, blue: 0, alpha: 0.1)
    static let Black = UIColor.rgb(red: 0, green: 0, blue: 0, alpha: 1)
    
    static let Blue = UIColor.rgb(red: 0, green: 122, blue: 255, alpha: 1)
    static let BlueWeakAlpha = UIColor.rgb(red: 0, green: 122, blue: 255, alpha: 0.9)
    static let BlueAlpha = UIColor.rgb(red: 0, green: 122, blue: 255, alpha: 0.3)
    static let BlueUltraAlpha = UIColor.rgb(red: 0, green: 122, blue: 255, alpha: 0.1)
    
    static let AuthLightBlue = UIColor.rgb(red: 121, green: 158, blue: 204, alpha: 1)
    
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    func createOnePixelImage() -> UIImage? {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
