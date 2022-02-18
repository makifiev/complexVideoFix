//
//  UIViewController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 03.08.2021.
//

import Foundation
import UIKit

extension UIView
{
    var setPosition : CGPoint
    {
        get {
            return objc_getAssociatedObject(self, &self.frame.origin) as! CGPoint
        }
        set {
            let frame:CGRect = CGRect(origin: newValue, size: self.frame.size)
            self.frame = frame
        }
    }
    
    var x : CGFloat {
        get {
            let position = self.frame.origin.x
            return position
        }
        set {
            self.frame.origin.x = newValue
            
        }
    }
    var y : CGFloat {
        get {
            let position = self.frame.origin.y
            return position
        }
        set {
            self.frame.origin.y = newValue
            
        }
    }
    
    
    var setSize: CGSize {
        get {
            return objc_getAssociatedObject(self, &self.frame.origin) as! CGSize
        }
        set {
            let frame:CGRect = CGRect(origin:  self.frame.origin, size: newValue)
            self.frame = frame
        }
    }
    //            objc_setAssociatedObject(self, &frame, newValue, .OBJC_ASSOCIATION_RETAIN)
    var size: CGSize
    {
        return self.frame.size
    }
    
    func setBlurWithSize(size: CGSize,
                         effect: UIVisualEffect)
    {
        let blurEffectView = UIVisualEffectView()
        blurEffectView.setSize = size
        blurEffectView.effect = effect
        blurEffectView.tag = Constant.BlurTag
        blurEffectView.isUserInteractionEnabled = false
        blurEffectView.layer.cornerRadius = self.layer.cornerRadius
        blurEffectView.clipsToBounds = true
        
        if !(self.isKind(of: UITableView.self))
        {
            self.addSubview(blurEffectView)
            self.sendSubviewToBack(blurEffectView)
        }
        else
        {
            (self as? UITableView)?.backgroundView = blurEffectView
        }
        
        if self.isKind(of: UIButton.self)
        {
            self.bringSubviewToFront((self as! UIButton).imageView!)
        }
    }
    func setBlur()
    {
        self.setBlurWithSize(size: self.size, effect: UIBlurEffect(style: UIBlurEffect.Style.extraLight))
    }
    func setBlurWithoutStyle(size: CGSize)
    {
        self.setBlurWithSize(size: size, effect: UIBlurEffect(style: UIBlurEffect.Style.extraLight))
    }
    func setDarkBlur()
    {
        self.setBlurWithSize(size: self.size, effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    }
    func removeChildren()
    {
        self.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}



