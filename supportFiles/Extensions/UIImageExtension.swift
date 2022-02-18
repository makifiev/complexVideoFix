//
//  UIImageExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 03.08.2021.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage
{
    func imageWithColor(tintColor: UIColor) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func setmarkerImage(drawText: String, font: UIFont, color: UIColor, alpha:CGFloat, atPoint: CGPoint, circleColor: UIColor?) -> UIImage
    {
        var atPoint = atPoint
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        
        if circleColor != nil
        {
            let radius = (self.size.width * 0.7) / 2
            let context: CGContext = UIGraphicsGetCurrentContext()!
            context.setFillColor(circleColor!.cgColor)
            context.closePath()
            context.fillPath()
        }
        
        let textSize = (drawText as NSString).boundingRect(with: CGSize.zero,
                                                           options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                           attributes: [NSAttributedString.Key.font: font],
                                                           context: nil).size
        
        if atPoint.x == -1
        {
            atPoint = CGPoint(x: ceil(self.size.width - textSize.width) / 2, y: atPoint.y)
        }
        if atPoint.y == -1
        {
            atPoint = CGPoint(x: atPoint.x, y: (self.size.height - textSize.height) / 2)
        }
        
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: self.size.width, height: self.size.height)
        let rectIntegral = rect.integral
        (drawText as NSString).draw(in: rectIntegral, withAttributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor : color])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    func pieChartWithArray(array: NSArray, colors: NSDictionary, radius: Float, stretch: Bool, sumColors: NSArray?, borderColor: UIColor?) -> UIImage?
    {
        var pieChart = drawPieChartWithArray(array: array, colors: colors, minRadius: radius, stretch: stretch)
        if sumColors != nil && sumColors?.count != 0
        {
            pieChart = drawText(pieChart: pieChart!,
                                text: "\(array.count)" as NSString,
                                font: Constant.setFontBold(size: CGFloat(Int(radius) - 5)),
                                color: sumColors?[0] as! UIColor,
                                alpha: 1,
                                point: CGPoint(x: -1, y: -1),
                                circleColor: sumColors?[1] as? UIColor)
        }
        if borderColor != nil
        {
            pieChart = drawBorderWithColor(pieChart: pieChart!, color: borderColor!, borderWidth: 2)
        }
        return pieChart
    }
    
    func drawPieChartWithArray(array: NSArray, colors: NSDictionary, minRadius: Float, stretch: Bool) -> UIImage?
    {
        var startRadian:Float = 0
        var endRadian:Float = 0
        
        var radius = minRadius
        let maxRadius = radius * 1.5
        
        if stretch
        {
            let multiplier = array.count / 30
            radius = minRadius * (multiplier > 1 ? Float(multiplier) : 1)
        }
        if radius > maxRadius
        {
            radius = maxRadius
        }
        if array.count != 0
        {
            let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: nil,
                                    width: Int(radius) * 2 + 1,
                                    height: Int(radius) * 2 + 1,
                                    bitsPerComponent: 8,
                                    bytesPerRow: 0,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            if context == nil
            {
                return nil
            }
            let sortedColors: NSMutableArray = []
            sortedColors.addObjects(from: colors.allKeys)
            sortedColors.sort(ascending: false)
            
            let values = NSMutableArray().getCountValues(arrays: [sortedColors,array])
            for i in stride(from: 0, to: sortedColors.count, by: 1)
            {
                let value = (values[i] as! Float) / Float(array.count)
                if value > 0
                {
                    context!.setFillColor((colors[sortedColors[i]] as! UIColor).cgColor)
                    endRadian = startRadian + value * Float(Double.pi  * 2)
                    context!.move(to: CGPoint(x: CGFloat(radius), y: CGFloat(radius)))
                    context!.addArc(center: CGPoint(x: CGFloat(radius), y: CGFloat(radius)),
                                    radius: CGFloat(radius), startAngle: CGFloat(startRadian), endAngle: CGFloat(endRadian), clockwise: false)
                    context!.closePath()
                    context!.fillPath()
                    startRadian = endRadian
                }
            }
            
            guard let pieChartContext = context?.makeImage()
            else
            { return nil }
            let pieChart = UIImage(cgImage: pieChartContext)
            
            return pieChart
        }
        print("Count = 0")
        return nil
    }
    
    func drawText(pieChart:UIImage, text: NSString, font: UIFont, color: UIColor, alpha: CGFloat, point: CGPoint, circleColor: UIColor?) -> UIImage?
    {
        var point = point
        UIGraphicsBeginImageContextWithOptions(pieChart.size, false, 0.0)
        pieChart.draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        if circleColor != nil
        {
            let radius = (pieChart.size.width * 0.7) / 2
            let context = UIGraphicsGetCurrentContext()
            context!.setFillColor(circleColor!.cgColor)
            context!.addArc(center: CGPoint(x: pieChart.size.width / 2, y: pieChart.size.height / 2),
                            radius: radius,
                            startAngle: 0,
                            endAngle: 7,
                            clockwise: false)
            context!.closePath()
            context!.fillPath()
        }
        let textSize = text.boundingRect(with: CGSize.zero,
                                         options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                         attributes: [.font: font],
                                         context: nil).size
        if point.x == -1
        {
            point = CGPoint(x: ceil(pieChart.size.width - textSize.width) / 2, y: point.y)
        }
        if point.y == -1
        {
            point = CGPoint(x: point.x, y: (pieChart.size.height - textSize.height) / 2)
        }
        let rect = CGRect(x: point.x, y: point.y, width: pieChart.size.width, height: pieChart.size.height)
        let rectIntegral = rect.integral
        text.draw(in: rectIntegral, withAttributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor : color])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawBorderWithColor(pieChart:UIImage, color: UIColor, borderWidth: CGFloat) -> UIImage?
    {
        var rect = CGRect(x: 0, y: 0, width: pieChart.size.width, height: pieChart.size.height)
        rect = rect.insetBy(dx: borderWidth * 0.5, dy: borderWidth * 0.5)
        UIGraphicsBeginImageContextWithOptions(pieChart.size, false, 0.0)
        pieChart.draw(in: rect)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(borderWidth)
        context.setStrokeColor(color.cgColor)
        context.strokeEllipse(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
