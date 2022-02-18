//
//  UILabelExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 05.08.2021.
//

import Foundation
import UIKit

extension UILabel
{
    func labelWithFrame(frame: CGRect, colors: NSArray)
    {
        let label = self
        label.frame = frame
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = (colors[0] as! UIColor)
        label.backgroundColor = (colors[1] as! UIColor)
        label.textAlignment = .left
    }
    
    func setLabelWithOutFrame(colors: NSArray)
    {
        let label = self
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = (colors[0] as! UIColor)
        label.backgroundColor = (colors[1] as! UIColor)
        label.textAlignment = .left
    }
}
