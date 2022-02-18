//
//  UITapGestureRecognizer.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 07.10.2021.
//

import Foundation
import UIKit

extension UILongPressGestureRecognizer
{
    
}


import UIKit


class TapAndCopyLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //1.Here i am Adding UILongPressGestureRecognizer by which copy popup will Appears
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        self.addGestureRecognizer(gestureRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    // MARK: - UIGestureRecognizer
    @objc func handleLongPressGesture(_ recognizer: UIGestureRecognizer) {
        guard recognizer.state == .began else { return }
        
        if let recognizerView = recognizer.view,
           let recognizerSuperView = recognizerView.superview, recognizerView.becomeFirstResponder()
        {
            let menuController = UIMenuController.shared
            if #available(iOS 13.0, *) {
                menuController.showMenu(from: recognizerSuperView, rect: recognizerView.frame)
            } else {
                menuController.setMenuVisible(true, animated: true)
            }
            //
            //            menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
            //            menuController.setMenuVisible(true, animated:true)
        }
    }
    //2.Returns a Boolean value indicating whether this object can become the first responder
    override var canBecomeFirstResponder: Bool {
        return true
    }
    //3.Here we are enabling copy action
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(UIResponderStandardEditActions.copy(_:)))
        
    }
    // MARK: - UIResponderStandardEditActions
    override func copy(_ sender: Any?) {
        //4.copy current Text to the paste board
        UIPasteboard.general.string = text
    }
}
