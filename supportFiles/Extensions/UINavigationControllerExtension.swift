//
//  UINavigationControllerExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 03.08.2021.
//

import Foundation
import UIKit

extension UINavigationController
{
    func initWithRootViewController(rootViewController: UITabBarController, noInteraction: Bool) -> UINavigationController
    {
        self.viewControllers = [rootViewController]
        if noInteraction
        {
            let noIntercationView = NoInteractionView.init(withNavigationController: self)
            self.view = noIntercationView
        }
        self.tuneNavigationBarWithBackground(backGround: nil)
        return self
    }
    func tuneNavigationBarWithBackground(backGround: UIImage?)
    {
        let navBar = self.navigationBar
        navBar.shadowImage = nil
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.DarkGray, NSAttributedString.Key.font: Constant.setFontBold(size: 15)]
        navBar.setBackgroundImage(backGround, for: .default)
        navBar.setBackgroundImage(backGround, for: .compact)
        
    }
}

