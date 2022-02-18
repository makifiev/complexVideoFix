//
//  UIBarButtonItemExtension.swift
//  UIBarButtonItemExtension
//
//  Created by Акифьев Максим  on 04.10.2021.
//

import Foundation
import UIKit

extension UIBarButtonItem
{
    func itemWithActivityIndicator(color: UIColor) -> UIBarButtonItem
    {
        let activityIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .white
        }
        activityIndicator.color = color
        activityIndicator.startAnimating()
        
        let buttonItem = UIBarButtonItem(customView: activityIndicator)
        
        return buttonItem
    }
}
