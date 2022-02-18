//
//  UIViewControllerExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 03.08.2021.
//

import Foundation
import UIKit

public extension UIViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if UIDevice().userInterfaceIdiom == .phone {
            let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            
            if AuthView.keyBoardHeightDiffer <= keyboardSize!.height
            
            {
                
                self.view.frame.origin.y = -keyboardSize!.height + AuthView.keyBoardHeightDiffer
                
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        _ = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        if self.view.frame.origin.y != 0
        {
            self.view.frame.origin.y = 0
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
