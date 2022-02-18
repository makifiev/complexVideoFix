//
//  CODDWorkReportController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 22.11.2021.
//

import Foundation
import UIKit

class CODDWorkReportController: UIViewController
{
    var mFormattedReport: NSDictionary!
    var mPanel = UIView()
    var mScroll = UIScrollView()
    var mLoadingIndicator = UIActivityIndicatorView()
    var mLoading = UILabel()
    var mCreateReport = UIButton()
    
    var mCreatingError = UILabel()
    
    var mDelegate: ReportsDelegate?
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = .clear
        self.edgesForExtendedLayout = []
        
        self.addPanel()
        self.addViews()
    }
    
    func addPanel()
    {
        mPanel = UIView()
        mPanel.frame = CGRect(x: -1, y: -1.5, width: self.view.frame.width + 2, height: CGFloat(66 + Constant.iPhoneNavBarCoefficient))
        mPanel.layer.borderWidth = 0.3
        mPanel.layer.borderColor = UIColor.DarkGrayAlpha.cgColor
        
        mPanel.setBlur()
        self.view.addSubview(mPanel)
        
        let title = UILabel()
        title.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        title.text = "Работа ЦОДД-ЦАФАП"
        title.font = Constant.setFontBold(size: 18)
        title.sizeToFit()
        title.center = CGPoint(x: mPanel.frame.width / 2, y: Constant.statusBarHeight + (mPanel.frame.height - Constant.statusBarHeight) / 2)
        mPanel.addSubview(title)
    }
    
    func addViews()
    {
        
        let background = UIView()
        background.frame = CGRect(x: 0, y: mPanel.frame.height + mPanel.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height - (mPanel.frame.origin.y + mPanel.frame.height) - Constant.tabBarHeight! + 5)
        background.backgroundColor = .White
        self.view.addSubview(background)
        
        mScroll = UIScrollView()
        mScroll.frame = background.frame
        mScroll.delaysContentTouches = false
        mScroll.alpha = 0
        
        self.view.addSubview(mScroll)
        
        self.addReport()
    }
    
    func addReport()
    {
        mLoadingIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            mLoadingIndicator.style = .medium
        } else {
            mLoadingIndicator.style = .white
        }
        mLoadingIndicator.color = UIColor.blue
        mLoadingIndicator.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        mLoadingIndicator.startAnimating()
        self.view.addSubview(mLoadingIndicator)
        
        mLoading.text = "Формирование отчета"
        mLoading.font = Constant.setMediumFont(size: 14)
        mLoading.sizeToFit()
        mLoading.center.x = mLoadingIndicator.center.x
        mLoading.frame.origin.y = mLoadingIndicator.frame.origin.y + mLoadingIndicator.frame.height + 20
        self.view.addSubview(mLoading)
        
        mCreateReport = UIButton()
        mCreateReport.setButtonWithTitle(title: "Сформировать отчет",
                                         font: Constant.setMediumFont(size: 18),
                                         colors: [UIColor.White,
                                                  UIColor.white.withAlphaComponent(0.3),
                                                  UIColor.Blue
                                         ])
        mCreateReport.titleLabel?.text = "Сформировать отчет"
        mCreateReport.frame = CGRect(x: 10, y: mLoadingIndicator.frame.origin.y - 13, width: self.view.frame.width - 20, height: 50)
        mCreateReport.alpha = 0
        mCreateReport.layer.cornerRadius = 5
        mCreateReport.addTarget(self, action: #selector(loadReport), for: .touchUpInside)
        self.view.addSubview(mCreateReport)
        
        mCreatingError = UILabel()
        mCreatingError.labelWithFrame(frame: CGRect(x: 5, y: mCreateReport.frame.origin.y - mCreatingError.frame.height - 10, width: self.view.frame.width - 10, height: 15), colors: [UIColor.DarkGray, UIColor.clear])
        mCreatingError.font = Constant.setMediumFont(size: 14)
        mCreatingError.textAlignment = .center
        mCreatingError.alpha = 0
        self.view.addSubview(mCreatingError)
        
        mDelegate?.showReportCreatingMarker(reportType: ReportType.ReportTypeCODDWork)
    }
    
    @objc func loadReport()
    {
        if Connectivity.isConnectedToInternet()
        {
            mDelegate?.showReportCreatingMarker(reportType: ReportType.ReportTypeCODDWork)
            
            UIView.animate(withDuration: 0.3)
            {
                self.mCreateReport.alpha = 0
                self.mCreatingError.alpha = 0
            }
            
            Networking.sharedInstance.loadCoddWorkReport { (report) in
                report.format { (formattedReport) in
                    self.mFormattedReport = formattedReport
                    self.addFunnels()
                    UIView.animate(withDuration: 0.3) {
                        self.mLoadingIndicator.alpha = 0
                        self.mLoading.alpha = 0
                        self.mScroll.alpha = 1
                    }
                    completion:
                    { (f: Bool) in
                        self.mLoadingIndicator.stopAnimating()
                        self.mLoadingIndicator.removeFromSuperview()
                        self.mLoading.removeFromSuperview()
                    }
                    self.mDelegate?.showReportReadyMarker(reportType: .ReportTypeCODDWork)
                    
                } failure: { (reason) in
                    self.showError(reason: reason)
                }
                
            } failure: { (reason) in
                self.showError(reason: reason)
            }
            
        }
        else
        {
            UIView.animate(withDuration: 0.3) {
                self.mCreateReport.alpha = 1
            }
        }
    }
    
    func showError(reason: String)
    {
        mCreatingError.text = reason
        UIView.animate(withDuration: 0.3)
        {
            self.mCreateReport.alpha = 1
            self.mCreatingError.alpha = 1
        }
        mDelegate?.showReportFailureMarker(reportType: ReportType.ReportTypeCODDWork)
    }
    
    func addFunnels()
    {
        let types = ["ВСЕГО", "ЦАФАП", "АМПП", "МАДИ"]
        var y = 0
        for type in types
        {
            let backGround = UIView(frame: CGRect(x: 0, y: y, width: Int(mScroll.frame.width), height: 40))
            backGround.backgroundColor = .GrayApha
            mScroll.addSubview(backGround)
            
            let title = UILabel()
            title.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
            title.text = type
            title.font = Constant.setMediumFont(size: 12)
            title.sizeToFit()
            title.setPosition = CGPoint(x: 10, y: backGround.frame.height - title.frame.height - 6)
            backGround.addSubview(title)
            
            let dict = mFormattedReport[type] as? NSDictionary ?? [:]
            
            let inValue = UILabel()
            inValue.labelWithFrame(frame: .zero, colors: [UIColor.Blue, UIColor.clear])
            inValue.text = String().stringFromNumber(number: dict["in"] as? Int ?? 0)
            inValue.font = Constant.setMediumFont(size: 17)
            inValue.frame.origin.y = backGround.frame.origin.y + backGround.frame.height + 15
            mScroll.addSubview(inValue)
            
            let funnel = UIImageView(image: UIImage(named: "funnel"))
            funnel.frame.origin.y = inValue.frame.origin.y + inValue.frame.height + 10
            mScroll.addSubview(funnel)
            
            if !Constant.iphone6
            {
                funnel.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                funnel.x = 10
            }
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                funnel.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                funnel.center.x = mScroll.frame.width / 2
            }
            else
            {
                funnel.center.x = mScroll.frame.width / 2
            }
            let outValues = dict["out"] as? NSArray ?? []
            
            for i in 0..<outValues.count
            {
                
                let outValue = outValues[i] as? NSDictionary ?? [:]
                let title = UILabel()
                title.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
                title.text = outValue.allKeys[safe: 0] as? String ?? ""
                title.font = Constant.setMediumFont(size: 12)
                title.sizeToFit()
                title.center.x = funnel.center.x
                title.frame.origin.y = CGFloat(((Constant.iphone6 ? 32 : 30) * i)) + funnel.frame.origin.y + (Constant.iphone6 ? 45 : 42)
                mScroll.addSubview(title)
                
                let numValue = outValue.allValues[safe: 0] as? Int ?? 0
                
                let value = UILabel()
                value.labelWithFrame(frame: .zero, colors: [UIColor.Blue, UIColor.clear])
                value.text = "\(String().stringFromNumber(number: numValue))\(numValue > 0 ? "-" : "")"
                value.font = Constant.setMediumFont(size: 17)
                value.sizeToFit()
                value.frame.origin.x = funnel.frame.origin.x + funnel.frame.width - 10
                value.center.y = title.center.y
                mScroll.addSubview(value)
            }
            let result = UILabel()
            result.labelWithFrame(frame: .zero, colors: [UIColor.Blue, UIColor.clear])
            result.text = String().stringFromNumber(number: dict["result"] as? Int ?? 0)
            result.font = Constant.setMediumFont(size: 17)
            result.sizeToFit()
            result.center.x = funnel.center.x
            result.frame.origin.y = funnel.frame.origin.y + funnel.frame.height + 10
            mScroll.addSubview(result)
            
            inValue.center.x = result.center.x
            y = Int(result.frame.origin.y + result.frame.height + 15)
        }
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: CGFloat(y))
    }
}
