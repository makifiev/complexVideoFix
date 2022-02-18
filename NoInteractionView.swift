//
//  NoInteractionView.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 20.07.2021.
//

import Foundation
import UIKit

enum NoInteractionViewType: Int
{
    case NoInteractionViewTypeView = 0
    case NoInteractionViewTypeTabBarController = 1
    case NoInteractionViewTypeNavigationController = 2
}

class NoInteractionView: UIView
{
    var mtype:NoInteractionViewType!
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
    
    init(asMainViewWithFrame:CGRect)
    {
        mtype = NoInteractionViewType.NoInteractionViewTypeView
        super.init(frame: asMainViewWithFrame)
    }
    
    init(withView:UIView)
    {
        mtype = NoInteractionViewType.NoInteractionViewTypeView
        super.init(frame: withView.frame)
    }
    
    init(withTabBarController:UITabBarController)
    {
        
        super.init(frame: withTabBarController.view.frame)
        
        for subview in withTabBarController.view.subviews
        {
            
            self.addSubview(subview)
            mtype = NoInteractionViewType.NoInteractionViewTypeTabBarController
        }
        
    }
    
    init(withNavigationController: UINavigationController)
    {
        super.init(frame: withNavigationController.view.frame)
        
        self.addSubview(withNavigationController.view)
        mtype = NoInteractionViewType.NoInteractionViewTypeNavigationController
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view: UIView in self.subviews
        {
            let viewClass:String = String(describing: Swift.type(of: view))
            print(viewClass)
            
            if viewClass == "UITransitionView"
            {
                if proceedTabBarControllerView(view: view, point: point, event: event ?? UIEvent())
                {
                    return true
                }
            }
            
            else if viewClass == "UILayoutContainerView"
            {
                if proceedNavigationControllerView(view: view, point: point, event: event ?? UIEvent())
                {
                    return true
                }
            }
            else
            {
                if view.isUserInteractionEnabled && !view.isHidden && view.point(inside: self.convert(point, to: view), with: event)
                {
                    return true
                }
                
            }
        }
        return false
    }
    
    func proceedTabBarControllerView(view:UIView, point:CGPoint, event: UIEvent) -> Bool
    {
        for subview in view.subviews
        {
            let subviewClass:String = String(describing: Swift.type(of: subview))
            if subviewClass == "UIViewControllerWrapperView"
            {
                for subsubView in subview.subviews
                {
                    if subsubView.isUserInteractionEnabled && !subsubView.isHidden && subsubView.point(inside: subview.convert(point, to: subsubView), with: event)
                    {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func proceedNavigationControllerView(view: UIView, point:CGPoint, event: UIEvent) -> Bool
    {
        for subview in view.subviews
        {
            //            let subviewClass:String = String(describing: Swift.type(of: view.superclass))
            let subviewClass:String = String(describing: Swift.type(of: subview))
            
            if subviewClass == "UINavigationTransitionView"
            {
                for subsubView in subview.subviews
                {
                    let subsubviewClass:String = String(describing: Swift.type(of: subsubView))
                    if subsubviewClass == "UIViewControllerWrapperView"
                    {
                        for subsubsubView in subsubView.subviews
                        {
                            if subsubsubView.isUserInteractionEnabled && !subsubsubView.isHidden && subsubsubView.point(inside: subsubView.convert(point, to: subsubsubView), with: event)
                            {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
}
