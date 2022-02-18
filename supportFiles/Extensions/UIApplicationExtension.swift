//
//  UIApplicationExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 05.08.2021.
//

import Foundation
import UIKit

extension UIApplication {
    
    var statusBarUIView: UIView? {
        
        if #available(iOS 13.0, *) {
            let tag = 3848245
            
            let keyWindow: UIWindow? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            
            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let height = keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = tag
                statusBarView.layer.zPosition = 999999
                
                keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
            
        } else {
            
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}
