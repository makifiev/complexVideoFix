//
//  ComplexMaintanceViewController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.06.2021.
//

import UIKit

enum ReportType: Int
{
    case Database = 100
    case ReportTypeComplexStatus = 101
    case ReportTypeDisabledComplex = 102
    case ReportTypeCODDWork = 103
    case ReportTypeMain = 104
}

protocol ReportsDelegate: AnyObject
{
    func pushViewController(controller: UIViewController)
    func showReportCreatingMarker(reportType: ReportType)
    func showReportReadyMarker(reportType: ReportType)
    func showReportFailureMarker(reportType: ReportType)
    func hideReportMarker(reportType: ReportType)
}

class ComplexStatusReportController: UIViewController, TableViewDelegate, UIScrollViewDelegate {
    
    var mPanel: UIView!
    var mScroll: UIScrollView!
    var mStateIndicator: UILabel!
    var mStateIndicatorDesc: UILabel!
    var mPieChart: UIImageView?
    var mLegend: UIView!
    var mLoadingIndicator: UIActivityIndicatorView!
    var mLoading: UILabel!
    var mCreateReport: UIButton!
    var mCreatingError: UILabel!
    
    var mReport = ComplexStatusReport()
    
    var mTable: TableView!
    
    var mtableYOffset: CGFloat = 0.0
    var mtableHeight: CGFloat = 0.0
    
    
    var array = ["1", "2"]
    weak var mDelegate: ReportsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        self.view.backgroundColor = .clear
        self.edgesForExtendedLayout = [] 
        self.addPanel()
        self.addViews()
        self.addReport()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePieChart), name: Notification.Name(Constant.dataBaseUpdated), object: nil)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.dataBaseUpdated), object: nil)
    }
    
    func addPanel()
    {
        mPanel = UIView()
        mPanel.frame = CGRect(x: -1, y: -1.5, width: self.view.frame.width + 2, height: CGFloat(66 + Constant.iPhoneNavBarCoefficient))
        mPanel.layer.borderWidth = 0.3
        mPanel.layer.backgroundColor = UIColor.DarkGrayAlpha.cgColor
        mPanel.setBlur()
        self.view.addSubview(mPanel)
        
        let title = UILabel()
        title.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        title.text = "Состояние парка КВФ"
        title.font = Constant.setFontBold(size: 18)
        title.sizeToFit()
        title.center = CGPoint(x: mPanel.frame.width / 2, y: Constant.statusBarHeight + (mPanel.frame.height - Constant.statusBarHeight) / 2)
        mPanel.addSubview(title)
    }
    func addViews()
    {
        let backGround = UIView()
        backGround.frame = CGRect(x: 0, y: mPanel.frame.origin.y + mPanel.frame.height, width: self.view.frame.width, height: self.view.frame.height - (mPanel.frame.origin.y + mPanel.frame.height) - Constant.tabBarHeight! + 2)
        backGround.backgroundColor = UIColor.White
        self.view.addSubview(backGround)
        
        mScroll = UIScrollView()
        mScroll.frame = backGround.frame
        mScroll.showsVerticalScrollIndicator = false 
        mScroll.delaysContentTouches = false
        mScroll.delegate = self
        self.view.addSubview(mScroll)
        self.addStateIndicator()
    }
    
    func addStateIndicator()
    {
        let backGround = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        backGround.backgroundColor = UIColor.GrayApha
        mScroll.addSubview(backGround)
        
        let stateIndicator = UILabel()
        stateIndicator.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        stateIndicator.text = "ИНДИКАТОР СОСТОЯНИЯ"
        stateIndicator.font = Constant.setMediumFont(size: 12)
        stateIndicator.sizeToFit()
        stateIndicator.setPosition = CGPoint(x: 10, y: backGround.frame.height - stateIndicator.frame.height - 6)
        backGround.addSubview(stateIndicator)
        
        mStateIndicator = UILabel()
        mStateIndicator.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        mStateIndicator.frame.origin.y = backGround.frame.origin.y + backGround.frame.height + 10
        mStateIndicator.font = Constant.setFontBold(size: 34)
        mScroll.addSubview(mStateIndicator)
        
        mStateIndicatorDesc = UILabel()
        mStateIndicatorDesc.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        mStateIndicatorDesc.font = Constant.setMediumFont(size: 17)
        mScroll.addSubview(mStateIndicatorDesc)
        self.updatePieChart()
    }
    
    @objc func updatePieChart()
    {
        let complexWorkStates = CoreDataStack.sharedInstance.getComplexWorkStates()
        let workStates = Constant.workStates
        workStates.sort(ascending: false)
        
        var values: NSMutableArray = []
        
        
        values = values.getCountValues(arrays: [workStates, complexWorkStates]) as! NSMutableArray
        
        let indexOfWork = values[workStates.index(of: Constant.work)] as! Double
        let indexOfWorkLimited = values[workStates.index(of: Constant.workLimited)]  as! Double
        let workValue = (indexOfWork + indexOfWorkLimited) / Double(complexWorkStates.count) * 100
        if workValue >= 95
        {
            mStateIndicator.text = "ОК"
            mStateIndicator.textColor = .Green
            
            mStateIndicatorDesc.text = "более 95% работают"
            mStateIndicatorDesc.textColor = .Green
        }
        else if workValue > 15
        {
            mStateIndicator.text = "НЕИСПРАВНОСТЬ"
            mStateIndicator.textColor = .Orange
            
            mStateIndicatorDesc.text = "менее 95% работают"
            mStateIndicatorDesc.textColor = .Orange
        }
        else
        {
            mStateIndicator.text = "ПЛОХО"
            mStateIndicator.textColor = .Red
            
            mStateIndicatorDesc.text = "менее 15% работают"
            mStateIndicatorDesc.textColor = .Red
        }
        mStateIndicator.frame.size.width = 0
        mStateIndicator.sizeToFit()
        mStateIndicator.center.x = mScroll.frame.width / 2
        
        mStateIndicatorDesc.frame.size.width = 0
        mStateIndicatorDesc.sizeToFit()
        mStateIndicatorDesc.center.x = mStateIndicator.center.x
        mStateIndicatorDesc.frame.origin.y = mStateIndicator.frame.origin.y + mStateIndicator.frame.height + 5
        var pieChart = UIImage()
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            pieChart = UIImage().pieChartWithArray(array: complexWorkStates,
                                                       colors: Constant.colors as NSDictionary,
                                                       radius: Float(self.view.frame.width) / 8.0,
                                                       stretch: true,
                                                       sumColors: nil,
                                                   borderColor: nil)!
        }
        else
        {
            pieChart = UIImage().pieChartWithArray(array: complexWorkStates,
                                                       colors: Constant.colors as NSDictionary,
                                                       radius: Float(self.view.frame.width) / 4.0,
                                                       stretch: true,
                                                       sumColors: nil,
                                                   borderColor: nil)!
        }
        
        if mPieChart == nil
        {
            mPieChart = UIImageView(image: pieChart)
            mPieChart!.center.x = self.view.frame.width / 2
            mPieChart!.frame.origin.y = mStateIndicatorDesc.frame.origin.y + mStateIndicatorDesc.frame.height + 15
            mScroll.addSubview(mPieChart!)
            
            mLegend = UIView()
            mLegend.frame.origin.y = mPieChart!.frame.origin.y + mPieChart!.frame.height + 15
            mScroll.addSubview(mLegend)
            
            var y = 0
            for i in 0..<Constant.workStates.count
            {
                let workState = Constant.workStates[i] as? Int
                let state = UIView()
                state.frame = CGRect(x: 10, y: y, width: 10, height: 10)
                state.backgroundColor = Constant.colors[workState ?? 0]
                state.layer.cornerRadius = state.frame.width / 2
                mLegend.addSubview(state)
                
                let title = UILabel()
                title.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
                title.setPosition = CGPoint(x: state.frame.origin.x + state.frame.width + 8, y: state.frame.origin.y - 4)
                title.text = Constant.workTitles[workState ?? 0]
                title.font = Constant.setMediumFont(size: 14)
                title.sizeToFit()
                mLegend.addSubview(title)
                y = Int(title.frame.origin.y + title.frame.height + 10)
            }
            mLegend.frame.size = CGSize(width: mScroll.frame.width, height: CGFloat(y))
        }
        else
        {
            mPieChart!.removeChildren()
            mPieChart!.image = pieChart
            
        }
        var fullAngle:Float = 0.0
        for i in 0..<workStates.count
        {
            let value = values[i] as! Float / Float(complexWorkStates.count)
            if value > 0
            {
                let angle = fullAngle + 180.0 * value
                let view = UIView()
                view.frame.size = CGSize(width: mPieChart!.frame.width, height: mPieChart!.frame.height)
                mPieChart!.addSubview(view)
                
                var valueString = ""
                if value < 0.01
                {
                    valueString = "\(round(value * 100))2%"
                }
                else
                {
                    valueString = "\(Int(round(value * 100)))%"
                }
                let valueLabel = UILabel()
                valueLabel.labelWithFrame(frame: CGRect.zero, colors: [UIColor.White, UIColor.clear])
                valueLabel.text = valueString
                valueLabel.font = Constant.setMediumFont(size: fontForPieChart(value: value))
                
                valueLabel.sizeToFit()
                valueLabel.center.x = view.frame.width / 2
                valueLabel.frame.origin.y = CGFloat(50 - (1 - value) * 40)
                valueLabel.transform = CGAffineTransform(scaleX: CGFloat(value) + 0.6, y: CGFloat(value) + 0.6)
                valueLabel.transform = CGAffineTransform(rotationAngle: -.pi * (90 - CGFloat(angle)) / 180)
                view.addSubview(valueLabel)
                
                view.transform = CGAffineTransform(rotationAngle: .pi * (90 - CGFloat(angle)) / 180)
                fullAngle += 360 * value
            }
        }
    }
    
    func fontForPieChart(value: Float) -> CGFloat
    {
        switch value {
        case 0.0 ... 0.1 :
            return CGFloat(14)
        case 0.11 ... 0.2 :
            return CGFloat(20)
        case 0.21 ... 0.3 :
            return CGFloat(24)
        case 0.31 ... 0.4 :
            return CGFloat(26)
        case 0.41 ... 0.5 :
            return CGFloat(30)
        case 0.51 ... 0.6 :
            return CGFloat(35)
        case 0.61 ... 1.0 :
            return CGFloat(40)
        default:
            return CGFloat(20)
        }
        
    }
    
    func addReport()
    {
        mLoadingIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            mLoadingIndicator.style = .medium
        } else {
            mLoadingIndicator.style = .white
        }
        mLoadingIndicator.color = .Blue
        mLoadingIndicator.center.x = mScroll.frame.width / 2
        mLoadingIndicator.frame.origin.y = mLegend.frame.origin.y + mLegend.frame.height + 15
        mLoadingIndicator.startAnimating()
        mScroll.addSubview(mLoadingIndicator)
        
        mLoading = UILabel()
        mLoading.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        mLoading.text = "Формирование отчета"
        mLoading.font = Constant.setMediumFont(size: 14)
        mLoading.sizeToFit()
        mLoading.center.x = mLoadingIndicator.center.x
        mLoading.frame.origin.y = mLoadingIndicator.frame.origin.y + mLoadingIndicator.frame.height + 20
        mScroll.addSubview(mLoading)
        
        mCreateReport = UIButton()
        mCreateReport.setButtonWithTitle(title: "Сформировать отчет", font: Constant.setMediumFont(size: 18), colors: [UIColor.white, UIColor.white.withAlphaComponent(0.3), UIColor.Blue])
        mCreateReport.frame = CGRect(x: 10, y: mLoadingIndicator.frame.origin.y - 13, width: mScroll.frame.width - 20, height: 50)
        mCreateReport.alpha = 0
        mCreateReport.layer.cornerRadius = 5
        mCreateReport.addTarget(self, action: #selector(loadReport), for: .touchUpInside)
        mScroll.addSubview(mCreateReport)
        
        mCreatingError = UILabel()
        mCreatingError.labelWithFrame(frame: CGRect(x: 5, y: mCreateReport.frame.origin.y + mCreateReport.frame.height + 10, width: mScroll.frame.width - 10, height: 15), colors: [UIColor.DarkGray, UIColor.clear])
        mCreatingError.font = Constant.setMediumFont(size: 14)
        mCreatingError.textAlignment = .center
        mCreatingError.alpha = 0
        mScroll.addSubview(mCreatingError)
        
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: mLoading.frame.origin.y + mLoading.frame.height + 15)
        self.loadReport()
    }
    @objc func loadReport()
    {
        mDelegate?.showReportCreatingMarker(reportType: ReportType.ReportTypeComplexStatus)
        UIView.animate(withDuration: 0.3)
        {
            self.mCreateReport.alpha = 0
            self.mCreatingError.alpha = 0
        }
        Networking.sharedInstance.loadComplexStatusReport(success: { (report) in
            self.mReport = report
            self.addWorkingComplexesAndFixations()
            UIView.animate(withDuration: 0.3)
            {
                self.mLoadingIndicator.alpha = 0
                self.mLoading.alpha = 0
                self.mTable.alpha = 1
            }
            completion:
            { (f: Bool) in
                self.mLoadingIndicator.stopAnimating()
                self.mLoadingIndicator.removeFromSuperview()
            }
            self.mDelegate?.showReportReadyMarker(reportType: ReportType.ReportTypeComplexStatus)
        }, failure: { (reason) in
            self.mCreatingError.text = reason
            UIView.animate(withDuration: 0.3)
            {
                self.mCreateReport.alpha = 1
                self.mCreatingError.alpha = 1
            }
            self.mScroll.contentSize = CGSize(width: self.mScroll.frame.width, height: self.mCreatingError.frame.origin.y + self.mCreatingError.frame.height + 15)
            self.mDelegate?.showReportFailureMarker(reportType: ReportType.ReportTypeComplexStatus)
        })
        
        
    }
    
    
    func addWorkingComplexesAndFixations()
    {
        mTable = TableView.init(withStyle: .grouped)
        
        mTable.frame = CGRect(x: 0, y: mLegend.frame.origin.y + mLegend.frame.height + 5, width: mScroll.frame.width, height: mScroll.frame.height)
        mTable.mTableViewDelegate = self
        
        mTable.isScrollEnabled = false
        mTable.alpha = 0
        mTable.setCell(cell: ComplexStatusReportCell.self)
        mTable.setDictionary(dictionary: ["Камеры": mReport.day1!, "Фиксации": mReport.day1!], ascending: true)
        self.mScroll.addSubview(mTable)
        mScroll.frame.size.height = mTable.contentSize.height
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: mTable.frame.origin.y + mTable.contentSize.height)
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath: IndexPath)
    {
        let cell = cell as! ComplexStatusReportCell
        let complexDay1:NSDictionary = mReport.day1[atIndexPath.row] as? NSDictionary ?? [:]
        let complexday2:NSDictionary = mReport.day2[atIndexPath.row] as? NSDictionary ?? [:]
        
        
        let valueKey = atIndexPath.section != 0 ? "pasCnt" : "camCnt"
        
        cell.setTitle(title: complexDay1["name"] as? String ?? "")
        cell.setValue(value: complexDay1[valueKey] as? Int ?? 0)
        cell.setValueDiff(valueDiff: (complexDay1[valueKey] as? Int ?? 0) - (complexday2[valueKey] as? Int ?? 0))
        cell.lineHidden = atIndexPath.row == 0
    }
    
    func heightForRowAtIndexPath(indexPath: IndexPath) -> CGFloat
    {
        let complex =  mReport.day1[indexPath.row] as? NSDictionary ?? [:]
        let width = mTable.frame.width - 50
        let valueKey = indexPath.section != 0 ? "pasCnt" : "camCnt"
        let title = (complex["name"] as? NSString ?? "")
        let titleRect = title.boundingRect(with: CGSize(width: width, height: 0),
                                           options: .usesLineFragmentOrigin,
                                           attributes:[NSAttributedString.Key.font: Constant.setMediumFont(size: 14)],
                                           context: nil)
        let value = "\(complex[valueKey] as? Int ?? 0)" as NSString
        let valueRect = value.boundingRect(with: CGSize(width: width, height: 0),
                                           options: .usesLineFragmentOrigin,
                                           attributes: [NSAttributedString.Key.font: Constant.setMediumFont(size: 17)],
                                           context: nil)
        print(titleRect.size.height + valueRect.size.height + 25)
        
        return titleRect.size.height + valueRect.size.height + 25
    }
    
    func viewForHeaderInSection(section: Int) -> UIView
    {
        let header = UIView()
        header.frame.size = CGSize(width: self.view.frame.width, height: 40)
        header.backgroundColor = UIColor.GrayApha
        
        let title = UILabel()
        title.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        title.text = section != 0 ?  "КОЛИЧЕСТВО ФИКСАЦИЙ" : "КОЛИЧЕСТВО РАБОТАЮЩИХ КОМПЛЕКСОВ"
        title.font = Constant.setMediumFont(size: 12)
        title.sizeToFit()
        title.setPosition = CGPoint(x: 10, y: header.frame.height - title.frame.height - 6)
        header.addSubview(title)
        
        return header
    }
    
    func heightForHeaderInSection(section: Int) -> CGFloat
    {
        return 40
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableViewHeight = mTable.frame.height
        
        if (scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height || mtableYOffset > 0) && (scrollView.contentOffset.y + scrollView.frame.height < scrollView.contentSize.height || mtableYOffset < mtableHeight - tableViewHeight)
        {
            let y = scrollView.contentSize.height - scrollView.frame.height
            mTable.contentOffset = CGPoint(x: mTable.contentOffset.x, y: mTable.contentOffset.y + scrollView.contentOffset.y - y)
            mtableYOffset = mTable.contentOffset.y
            mtableHeight = mTable.contentSize.height
            
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: y)
        }
        else if mtableYOffset <= 0
        {
            mTable.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }
        else if mtableYOffset >= mtableHeight - tableViewHeight
        {
            mTable.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: mtableHeight - tableViewHeight)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        mtableHeight = mTable.contentSize.height
    }
}
