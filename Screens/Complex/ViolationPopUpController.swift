//
//  ViolationPopUpController.swift
//  ViolationPopUpController
//
//  Created by Акифьев Максим  on 12.10.2021.
//

import Foundation
import UIKit

class ViolationPopUpController:UIViewController
{
    var mId: Int!
    
    init(withId:Int)
    {
        mId = withId
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = UIView(frame: Constant.mainFrame)
        self.edgesForExtendedLayout = []
        
        let violation: Violation? = CoreDataStack.sharedInstance.getViolations(id: mId)
        var imageName:String!
        
        if violation?.violValueUnit == "км/ч"
        {
            imageName = "icon-id-speed-\(violation?.violValueLimit != nil ? violation!.violValueLimit : 5)-large"
        }
        else
        {
            imageName = "icon-id-\(String(describing: violation?.violId))-large"
        }
        let image: UIImageView = UIImageView(image: UIImage(named: imageName))
        image.center.x = self.view.frame.width / 2
        image.frame.origin.y = 50
        self.view.addSubview(image)
        
        let title: UILabel = UILabel()
        title.labelWithFrame(frame: CGRect(x: 0, y: image.y + image.frame.height + 10, width: self.view.frame.width - 20, height: 0), colors: [UIColor.White, UIColor.clear])
        title.text = "\(String(describing: violation?.violId)).\(String(describing: violation?.violName))"
        title.font = Constant.setMediumFont(size: 24)
        title.textAlignment = .center
        title.sizeToFit()
        title.center.x = image.center.x
        self.view.addSubview(title)
    }
    override var shouldAutorotate: Bool
    {
        return false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
