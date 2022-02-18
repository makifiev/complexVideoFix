//
//  ReportHistoryController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.11.2021.
//

import Foundation
import UIKit
import CoreData

class ReportHistoryController: UIViewController, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource
{
    var mHistory: NSDictionary = [:]
    var mDays: NSMutableArray = []
    var mTitle: String = ""
    
    var mDay: UILabel!
    var mValue: UILabel!
    
    var mNoData: Bool = false
    
    
    init(withHistory: NSDictionary, title: String)
    {
        super.init(nibName: nil, bundle: nil)
        if withHistory is NSDictionary && (withHistory as NSDictionary).allKeys.count != 0
        {
            mHistory = self.getFormattedHistory(history: withHistory)!
        }
        else
        {
           mNoData = true
        }
        mTitle = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getFormattedHistory(history: NSDictionary) -> NSDictionary?
    {
        let dict: NSMutableDictionary = [:]
        for day in history.allKeys as! [String]
        {
            let formattedDay = Date.stringFromDate(dateString: day, formats: ["EEE MMM dd HH:mm:ss 'MSK' yyyy", "yyyy.MM.dd"], enLocale: true)
            dict.setObject(day, forKey: formattedDay as NSCopying)
        }
        mDays = NSMutableArray(array: dict.allKeys)
        mDays.sort(ascending: true)
        
        let formattedHistory: NSMutableDictionary = [:]
        for i in 0..<mDays.count
        {
            formattedHistory.setValue(history[dict[mDays[i]]!], forKey: mDays[i] as! String)
        }
        return formattedHistory
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "История"
        self.view.backgroundColor = .White
        self.edgesForExtendedLayout = []
        
        self.addLabels()
        self.addGraph()
    }
    
    func addLabels()
    {
        let backGround = UIView()
        backGround.frame.size = CGSize(width: self.view.frame.width, height: 40)
        backGround.backgroundColor = .White
        self.view.addSubview(backGround)
        
        let bg = UIView()
        bg.frame.size = backGround.frame.size
        bg.backgroundColor = .GrayApha
        backGround.addSubview(bg)
        
        let title = UILabel()
        title.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        title.frame.size.width = backGround.frame.width - 20
        title.text = mTitle.uppercased()
        title.font = Constant.setMediumFont(size: 12)
        title.sizeToFit()
        backGround.addSubview(title)
        
        backGround.frame.size.height = title.frame.height + 26
        bg.frame.size.height = backGround.frame.height
        title.setPosition = CGPoint(x: 10, y: backGround.frame.height - title.frame.height - 6)
        
        mDay = UILabel()
        mDay.labelWithFrame(frame: CGRect(x: 10, y: backGround.frame.origin.y + backGround.frame.height + 20, width: self.view.frame.width - 20, height: 17), colors: [UIColor.DarkGray, UIColor.clear])
        mDay.textAlignment = .center
        mDay.font = Constant.setMediumFont(size: 17)
        mDay.text = mNoData ? "Нет данных" : self.formatDay(day: mDays[0] as! String)
        self.view.addSubview(mDay)
        
        mValue = UILabel()
        mValue.labelWithFrame(frame: CGRect(x: 10, y: mDay.frame.origin.y + mDay.frame.height + 10, width: self.view.frame.width - 20, height: 34), colors: [UIColor.Blue, UIColor.clear])
        mValue.textAlignment = .center
        mValue.font = Constant.setMediumFont(size: 34)
        if mHistory.count != 0
        {
        mValue.text = "\(mHistory[mDays[0]] as? Int ?? 0)"
        }
        else
        {
        mValue.text = "0"
        }
        self.view.addSubview(mValue)
    }
     
    func addGraph()
    {
       if !mNoData
       {
        let graph = BEMSimpleLineGraphView()
        let firstElement = self.view.frame.height - (mValue.frame.origin.y + mValue.frame.height)
        graph.frame = CGRect(x: 0, y: mValue.frame.origin.y + mValue.frame.height, width: self.view.frame.width, height: firstElement - 10 - Constant.topBarHeight - CGFloat(Constant.iPhoneXTabBarCoefficient + 30))
        graph.enableBezierCurve = true
        graph.enableTouchReport = true
        graph.alphaTop = 0
        graph.alphaBottom = 0
        graph.colorLine = .Blue
        graph.colorBottom = .BlueAlpha
        graph.colorPoint = .BlueAlpha
        graph.sizePoint = 20
        graph.enableYAxisLabel = false
        graph.colorXaxisLabel = .DarkGray
        graph.colorYaxisLabel = .DarkGray
        graph.colorBackgroundPopUplabel = .White
        graph.alphaBackgroundXaxis = 0
        graph.alphaBackgroundYaxis = 0
        graph.labelFont = Constant.setMediumFont(size: 14)
        graph.animationGraphEntranceTime *= CGFloat(mDays.count / 7)
        graph.displayDotsWhileAnimating = false
        graph.dataSource = self
        graph.delegate = self
        self.view.addSubview(graph)
        
        if mHistory.allKeys.count == 1
        {
            graph.isUserInteractionEnabled = false
        }
       }
    }
    
    func numberOfYAxisLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return 2
    }
    
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return mDays.count
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        return mHistory[mDays[index]] as! CGFloat
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, labelOnXAxisFor index: Int) -> String? {
        return self.formatDay(day: mDays[index] as! String)
    }
    
    func numberOfGapsBetweenLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return mDays.count
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: Int) {
        mDay.text = self.formatDay(day: mDays[index] as! String)
        mValue.text = "\(mHistory[mDays[index]] as? Int ?? 0)"
    }
    
    func formatDay(day: String) -> String
    {
        return Date.stringFromDate(dateString: day,
                                   formats: ["yyyy.MM.dd", "dd.MM.yyyy"],
                                   enLocale: false)
    }
    
}
