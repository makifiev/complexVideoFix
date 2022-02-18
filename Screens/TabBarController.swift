//
//  TabBarController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.06.2021.
//

import Foundation
import UIKit


class TabBarViewController: UITabBarController, UINavigationControllerDelegate, UITextFieldDelegate, MapControllerDelegate, ReportsDelegate
{
    
    
    func pushViewController(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    static var tabBarHeight:CGFloat!
    static var navigationBarHeight: CGFloat!
    static var StatusBarColor:UIColor!
    var firstlaunch = true
    var mTabBar:UIView!
    
    let blueColor:UIColor = UIColor.rgb(red: 25, green: 137, blue: 250, alpha: 1)
    let lightGrayColor:UIColor = UIColor.rgb(red: 177, green: 182, blue: 194, alpha: 1)
    var mMapController: MapViewController?
    var mSearchController: SearchViewController?
    var mDisabledComplexReportController: DisabledComplexReportController?
    var mCoddWorkReportController: CODDWorkReportController?
    var mDataNotUpdated: Bool = false
    var mReportsLoaded: Bool = false
    let DefaultSelectedIndex = 1
    var firstLaunch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mMapController?.mDelegate = self
        addNoIteractionView()
        setTabBar()
        
        self.selectedIndex = DefaultSelectedIndex
    }
    func pushViewController(controlelr: UIViewController) {
        self.navigationController?.pushViewController(controlelr, animated: true)
    }
    
    func hideSearchPanel()
    {
        mSearchController?.hidePanel()
    }
    
    func showSearchPanel()
    {
        mSearchController?.showPanel()
    }
    func showCopyAlertlabel(text: String) {
        mSearchController?.showCopyAlertlabel(text: text)
    }
    
    func addNoIteractionView()
    {
        self.view = NoInteractionView.init(withTabBarController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if firstLaunch
        {
            firstLaunch = false
            self.selectedIndex = 0
            self.selectedIndex = 4
            self.selectedIndex = 2
            self.selectedIndex = 3
            self.selectedIndex = 1
            selectTab(tag:1)
        }
    }
    
    override func loadView() {
        super.loadView()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        mMapController = appDelegate.mapController
        mMapController?.mDelegate = self
        
        
        mSearchController = self.viewControllers![0] as? SearchViewController
        mSearchController?.mDelegate = mMapController
        
        
        let complexStatusReportController = self.viewControllers![1] as? ComplexStatusReportController
        complexStatusReportController?.mDelegate = self
        
        
        mDisabledComplexReportController = self.viewControllers![2] as? DisabledComplexReportController
        mDisabledComplexReportController?.mDelegate = self
        
        mCoddWorkReportController = self.viewControllers![3] as? CODDWorkReportController
        mCoddWorkReportController?.mDelegate = self
        
        let reportBuilderController = self.viewControllers![4] as? ReportBuilderController
        reportBuilderController?.mDelegate = self
        
    }
    
    
    func setTabBar()
    {
        if (mTabBar == nil)
        {
            self.tabBar.alpha = 0;
            self.moreNavigationController.delegate = self
            mTabBar = UIView(frame: self.tabBar.frame)
            mTabBar.frame = CGRect(x: -1, y: self.tabBar.frame.origin.y - CGFloat(Constant.iPhoneXTabBarCoefficient), width: self.tabBar.frame.width + 2, height: self.tabBar.frame.height + 1 + CGFloat(Constant.iPhoneXTabBarCoefficient))
            TabBarViewController.tabBarHeight = mTabBar.frame.height
            TabBarViewController.StatusBarColor = navigationController?.navigationBar.backgroundColor
            TabBarViewController.navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
            mTabBar.backgroundColor = navigationController?.navigationBar.backgroundColor
            mTabBar.layer.borderWidth = 0.3
            mTabBar.layer.borderColor = UIColor.DarkGrayAlpha.cgColor
            mTabBar.setBlur()
            self.view.addSubview(mTabBar)
            
            let tabImages = ["map-marker", "reports", "broken-kvf", "zafap-report", "system-state"]
            
            for i:Int in stride(from: 0, to: tabImages.count, by: 1)
            {
                let tint:UIColor = (i == 0) ? blueColor : lightGrayColor
                let button:CenteredButton = CenteredButton()
                button.frame.size = CGSize(width: CGFloat(Float(tabBar.frame.size.width / 1.5) / Float(tabImages.count)), height: tabBar.frame.size.height)
                let buttonspace = (i != 0) ? (mTabBar.frame.width / 3) : 0
                let checkI = (i != 0) ? Double(1.5) : 1
                let cTabBarWidthCheck = Double(mTabBar.frame.width) / Double(tabImages.count) / Double(checkI)
                button.frame.origin.x = CGFloat(Double(i) * cTabBarWidthCheck) + buttonspace
                button.setImage(UIImage(named: tabImages[i])?.imageWithColor(tintColor: tint), for: .normal)
                button.addTarget(self, action: #selector(tabDidSelect(tab:)), for: .touchUpInside)
                button.tag = 10 + i
                mTabBar.addSubview(button)
                var diff: CGFloat!
                if UIScreen.main.bounds.height > 800
                {
                    diff = 3
                }
                else
                {
                    diff = 0
                }
                
                let greenIndicator = UIImageView()
                greenIndicator.frame = CGRect(x: 0, y: 10 - diff, width: 14, height: 14)
                greenIndicator.center.x = button.frame.origin.x + (button.frame.width / 2) + 10
                greenIndicator.layer.cornerRadius = greenIndicator.frame.width / 2
                greenIndicator.alpha = 0
                greenIndicator.tag = 100 + i
                mTabBar.addSubview(greenIndicator)
            }
        }
    }
    
    @objc func tabDidSelect(tab:UIButton)
    {
        self.selectedIndex = tab.tag - 10
        
        selectTab(tag:self.selectedIndex)
    }
    
    func selectTab(tag:Int)
    {
        for i:Int in stride(from: 0, to: mTabBar.subviews.count, by: 1)
        {
            if let button:CenteredButton = mTabBar.subviews[i] as? CenteredButton
            {
                let tint:UIColor = (button.tag == tag + 10) ? blueColor : lightGrayColor
                let tintHighlighted:UIColor = tint.withAlphaComponent(0.5)
                
                button.setImage(button.imageView?.image?.imageWithColor(tintColor: tint), for: .normal)
                button.setTitleColor(tint, for: .normal)
                button.setTitleColor(tintHighlighted, for: .highlighted)
            }
        }
    }
    
    @objc func updateData()
    {
        mDataNotUpdated = false
        self.showReportCreatingMarker(reportType: ReportType.Database)
        Networking.sharedInstance.loadComplexesWithProgress(progress: nil)
        {
            NotificationCenter.default.post(name: Notification.Name(Constant.dataBaseUpdated), object: nil)
            self.showReportReadyMarker(reportType: ReportType.Database)
            self.loadReports()
        } failure: {
            self.mDataNotUpdated = true
            self.showDataUpdateFailureAlert()
            self.showReportFailureMarker(reportType: ReportType.Database)
            self.loadReports() 
        }
    }
    
    func loadReports()
    {
        if !mReportsLoaded
        {
            mReportsLoaded = true
            mDisabledComplexReportController?.loadReport()
            mCoddWorkReportController?.loadReport()
        }
    }
    
    func showDataUpdateFailureAlert()
    {
        let alert: UIAlertController = UIAlertController(title: "Ошибка",
                                                         message: "Не удалось обновить список камер!",
                                                         preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler:
                                        {_ in
                                            self.updateData()
                                        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showReportCreatingMarker(reportType: ReportType) {
        self.showReportMarker(image: UIImage(named: "dot-overlay-clock")!, reportType: reportType)
    }
    
    func showReportReadyMarker(reportType: ReportType) {
        self.showReportMarker(image: UIImage(named: "dot-overlay-ready")!, reportType: reportType)
    }
    
    func showReportFailureMarker(reportType: ReportType) {
        self.showReportMarker(image: UIImage(named: "dot-overlay-error")!, reportType: reportType)
    }
    
    func hideReportMarker(reportType: ReportType) {
        let reportMarker = mTabBar.viewWithTag(reportType.rawValue) as! UIImageView
        UIView.animate(withDuration: 0.3)
        {
            reportMarker.alpha = 0
        }
    }
    
    func showReportMarker(image: UIImage, reportType: ReportType)
    {
        
        let reportMarker = mTabBar.viewWithTag(reportType.rawValue) as! UIImageView
        if reportMarker.image != image
        {
            UIView.animate(withDuration: 0.3)
            {
                reportMarker.alpha = 0
            }
            completion:
            { (f: Bool) in
                reportMarker.image = image
                UIView.animate(withDuration: 0.3)
                {
                    reportMarker.alpha = 1
                }
            }
        }
    }
    
}
