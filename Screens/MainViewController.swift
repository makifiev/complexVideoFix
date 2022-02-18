//
//  MainViewController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 19.07.2021.
//

import Foundation
import UIKit
import GoogleMaps

class MainViewController: UIViewController {
    
    var controllerLoaded:Bool!
    var mTabBarController : TabBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = NoInteractionView.init(asMainViewWithFrame: Constant.mainFrame)
        
        self.edgesForExtendedLayout = []
        guard let mapController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "mapController") as? MapViewController else {
            fatalError("Unable to Instantiate Image View Controller")
        }
        self.addChild(mapController)
        self.view.addSubview(mapController.view)
        mapController.didMove(toParent: self)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mapController = mapController
        
        mTabBarController = (UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController)!
        let SecondNavContr:UINavigationController = UINavigationController(nibName: "SecondNavContr", bundle: nil).initWithRootViewController(rootViewController: mTabBarController, noInteraction: true)
        SecondNavContr.viewControllers = [mTabBarController]
        SecondNavContr.setNavigationBarHidden(true, animated: false)
        self.addChild(SecondNavContr)
        self.view.addSubview(SecondNavContr.view)
        SecondNavContr.didMove(toParent: self)
        
        
        let defaults = UserDefaults.standard
        print(defaults.bool(forKey: Constant.dataBaseCreated))
        if defaults.bool(forKey: Constant.dataBaseCreated) == false
        {
            defaults.setValue(true, forKey: Constant.dataBaseCreated)
            
            defaults.synchronize()
            
            mTabBarController.showReportReadyMarker(reportType: .Database)
            mTabBarController.loadReports()
        }
        else
        {
            defaults.setValue(false, forKey: "afterBlackOut")
            mTabBarController.showReportCreatingMarker(reportType: .Database)
            mTabBarController.perform(#selector(mTabBarController.updateData), with: nil, afterDelay: 5)
        }
        controllerLoaded = false
    }
    
    override func viewDidLayoutSubviews() {
        
    }
}

