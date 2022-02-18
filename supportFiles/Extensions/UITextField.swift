//
//  UITextField.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 14.11.2021.
//

import Foundation
import UIKit

extension UITextField
{
    func textFieldWithFrame(frame: CGRect, font: UIFont, colors: NSArray, placeHolder: String)
    {
        let textField = self
        textField.frame = frame
        textField.contentVerticalAlignment = .center
        textField.backgroundColor = colors[1] as? UIColor
        textField.font = font
        textField.textColor = colors[0] as? UIColor
        textField.autocorrectionType = .no
        textField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor : colors[0] as! UIColor])
    }
    
    func searchFieldWithWidth(width: Float, colors: NSArray, placeHolder: String)
    {
        let textField = self
        textField.textFieldWithFrame(frame: CGRect(x: 0, y: 0, width: Int(width), height: 28),
                                     font: Constant.setMediumFont(size: 14),
                                     colors: colors,
                                     placeHolder: placeHolder)
        textField.autocorrectionType = .no
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 4
    }
    
    func setLeftImage(image: String)
    {
        let paddingView = UIView()
        let imageView = UIImageView(image: UIImage(named: image))
        imageView.frame.origin.x = 7
        paddingView.addSubview(imageView)
        
        paddingView.frame.size = CGSize(width: imageView.frame.origin.x + imageView.frame.width + 6, height: imageView.frame.height)
        
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
