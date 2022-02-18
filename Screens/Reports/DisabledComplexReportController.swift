//
//  ComplexReportsViewController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.06.2021.
//

import UIKit

class DisabledComplexReportController: UIViewController, UITableViewDataSource, UITableViewDelegate, RATreeViewDataSource, RATreeViewDelegate {
    
    
    
    
    
    var mFormattedReport: NSArray = []
    var mPanel = UIView()
    var mLoadingIndicator = UIActivityIndicatorView()
    var mLoading = UILabel()
    var mCreateReport = UIButton()
    var mCreatingError = UILabel()
    var mReportTree: RATreeView!
    
    weak var mDelegate: ReportsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.edgesForExtendedLayout = []
        
        self.addPanel()
        self.addViews()
        self.addReport()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        title.text = "Неработоспособные КВФ"
        title.font = Constant.setFontBold(size: 18)
        title.sizeToFit()
        title.center = CGPoint(x: mPanel.frame.width / 2, y: Constant.statusBarHeight + (mPanel.frame.height - Constant.statusBarHeight) / 2)
        mPanel.addSubview(title)
    }
    
    func addViews()
    {
        let backGround = UIView()
        backGround.frame = CGRect(x: 0, y: mPanel.frame.origin.y + mPanel.frame.height, width: self.view.frame.width, height: self.view.frame.height - (mPanel.frame.origin.y + mPanel.frame.height) - Constant.tabBarHeight! + 5)
        backGround.backgroundColor = .White
        self.view.addSubview(backGround)
        
        mReportTree = RATreeView.init()
        mReportTree.frame = backGround.frame
        mReportTree.alpha = 0
        mReportTree.delegate = self
        mReportTree.dataSource = self
        mReportTree.separatorStyle = RATreeViewCellSeparatorStyleSingleLineEtched
        self.view.addSubview(mReportTree)
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
        mLoadingIndicator.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        mLoadingIndicator.startAnimating()
        self.view.addSubview(mLoadingIndicator)
        
        mLoading = UILabel()
        mLoading.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        mLoading.text = "Формирование отчета"
        mLoading.font = Constant.setMediumFont(size: 14)
        mLoading.sizeToFit()
        mLoading.center.x = mLoadingIndicator.center.x
        mLoading.frame.origin.y = mLoadingIndicator.frame.origin.y + mLoadingIndicator.frame.height + 20
        self.view.addSubview(mLoading)
        
        mCreateReport = UIButton()
        mCreateReport.setButtonWithTitle(title: "",
                                         font: Constant.setMediumFont(size: 18),
                                         colors: [UIColor.White , UIColor.White.withAlphaComponent(0.3), UIColor.Blue])
        mCreateReport.frame = CGRect(x: 10, y: mLoadingIndicator.frame.origin.y - 13, width: self.view.frame.width - 20, height: 50)
        mCreateReport.alpha = 0
        mCreateReport.layer.cornerRadius = 5
        mCreateReport.addTarget(self, action: #selector(loadReport), for: .touchUpInside)
        self.view.addSubview(mCreateReport)
        
        mCreatingError = UILabel()
        mCreatingError.labelWithFrame(frame: CGRect(x: 5, y: mCreatingError.frame.origin.y + mCreatingError.frame.height + 10, width: self.view.frame.width - 10, height: 15), colors: [UIColor.DarkGray, UIColor.clear])
        mCreatingError.font = Constant.setMediumFont(size: 14)
        mCreatingError.textAlignment = .center
        mCreatingError.alpha = 0
        self.view.addSubview(mCreatingError)
        
        mDelegate?.showReportCreatingMarker(reportType: ReportType.ReportTypeDisabledComplex)
    }
    
    @objc func loadReport()
    {
        if Connectivity.isConnectedToInternet()
        {
            mDelegate?.showReportCreatingMarker(reportType: ReportType.ReportTypeDisabledComplex)
            UIView.animate(withDuration: 0.3) {
                self.mCreateReport.alpha = 0
                self.mCreatingError.alpha = 0
            }
            Networking.sharedInstance.loadDisabledComplexReport {[self] (report) in
                report.format { (formattedReport) in
                    mFormattedReport = formattedReport
                    
                   
                    UIView.animate(withDuration: 0.3) {
                        mLoadingIndicator.alpha = 0
                        mLoading.alpha = 0
                        mReportTree.alpha = 1
                    } completion: { (f: Bool) in
                        mLoadingIndicator.stopAnimating()
                        mLoadingIndicator.removeFromSuperview()
                        mLoading.removeFromSuperview()
                        self.mReportTree.reloadData()
                    }
                    mDelegate?.showReportReadyMarker(reportType: ReportType.ReportTypeDisabledComplex)
                } failure: { (reason) in
                    showError(error: reason)
                }
                
            } failure: { (reason) in
                self.showError(error: reason)
            }
            
        }
        else
        {
            UIView.animate(withDuration: 0.3)
            {
                self.mCreateReport.alpha = 1
            }
        }
    }
    
    func showError(error: String)
    {
        mCreatingError.text = error
        UIView.animate(withDuration: 0.3)
        {
            self.mCreateReport.alpha = 1
            self.mCreatingError.alpha = 1
        }
        mDelegate?.showReportFailureMarker(reportType: ReportType.ReportTypeDisabledComplex)
    }
    
    func treeView(_ treeView: RATreeView, estimatedHeightForRowForItem item: Any) -> CGFloat {
        return self.treeView(treeView, heightForRowForItem: item)
    }
    func treeView(_ treeView: RATreeView, heightForRowForItem item: Any) -> CGFloat {
        var extraHeight: Int!
        var width: CGFloat!
        var title: NSString!
        var fontSize: CGFloat!
        
        if item is NSArray
        {
            let item = item as! NSArray
            title = item[0] as? NSString
            fontSize = 14
            
            let level = treeView.levelForCell(forItem: item)
            width = treeView.frame.width - (20 * CGFloat(level)) - 147
            extraHeight = 45
        }
        else
        {
            title = "\(item)" as NSString
            fontSize = 12
            
            width = treeView.frame.width - 20
            extraHeight = 26
        }
        let rect = title.boundingRect(with: CGSize(width: width, height: 0),
                                      options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                      attributes: [NSAttributedString.Key.font: Constant.setMediumFont(size: fontSize)],
                                      context: nil)
        return rect.size.height + CGFloat(extraHeight)
    }
    
    func treeView(_ treeView: RATreeView, shouldExpandRowForItem item: Any) -> Bool {
        if item is NSArray
        {
            let item = item as! NSArray
            let cell = treeView.cell(forItem: item) as! DisabledComplexReportCell
            cell.setArrowOpen(arrowOpen: true)
            let children = item[5] as! NSArray
            return children.count != 0
        }
        return false
    }
    
    func treeView(_ treeView: RATreeView, didExpandRowForItem item: Any) {
        if item is NSArray
        {
            let item = item as! NSArray
            let children = item[5] as! NSArray
            if children.count != 0
            {
                treeView.scrollToRow(forItem: item, at: RATreeViewScrollPositionTop, animated: true)
            }
            else
            {
                treeView.scrollToRow(forItem: item, at: RATreeViewScrollPositionNone, animated: true)
            }
        }
    }
    
    func treeView(_ treeView: RATreeView, shouldCollapaseRowForItem item: Any) -> Bool {
        if item is NSArray
        {
            let item = item as! NSArray
            let cell = treeView.cell(forItem: item) as! DisabledComplexReportCell
            cell.setArrowOpen(arrowOpen: false)
            
            let children = item[5] as! NSArray
            return children.count != 0
        }
        return false
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        var cell = treeView.dequeueReusableCell(withIdentifier: NSStringFromClass(DisabledComplexReportCell.self)) as? DisabledComplexReportCell
        if cell == nil
        {
            cell = DisabledComplexReportCell.init(style: .subtitle,
                                                  reuseIdentifier: NSStringFromClass(DisabledComplexReportCell.self))
            cell!.selectionStyle = .none
        }
        if item is NSArray
        {
            let item = item as! NSArray
            let level = treeView.levelForCell(forItem: item)
            let children = item[5] as! NSArray
            
            cell!.setArrowHidden(arrowIsHidden: children.count == 0)
            cell!.setArrowOpen(arrowOpen: treeView.isCell(forItemExpanded: item))
            cell!.setLevel(level: level)
            cell!.setTitle(title: item[0] as! String)
            cell!.setValue(value: item[1] as! Int)
            cell!.setMinus(minus: item[3] as! Int)
            cell!.setPlus(plus: item[2] as! Int)
            cell!.setPlusMinusHidden(plusMinusHidden: false)
            //            cell!.setlineHidden(lineHidden: false)
        }
        else
        {
            cell!.setSection(section: "\(item ?? "")")
            cell!.setPlusMinusHidden(plusMinusHidden: true)
            //            cell!.setlineHidden(lineHidden: true)
            cell!.setArrowHidden(arrowIsHidden: true)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int
    {
        if item == nil
        {
            return mFormattedReport.count
        }
        if item is NSArray
        {
            let item = item as! NSArray
            let children = item[5] as! NSArray
            return children.count
        }
        return 0
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any
    {
        if item == nil
        {
            return mFormattedReport[index]
        }
        
        let item = item as! NSArray
        let children = item[5] as! NSArray
        return children[index]
    }
    
    
    func treeView(_ treeView: RATreeView, trailingSwipeActionsConfigurationForItem item: Any) -> UISwipeActionsConfiguration? {
        if item is NSArray
        {
            let item = item as! NSArray
            let titles = ["Список КВФ", "-", "+"] as NSArray
            var images = ["report-list-icon-tall", "report-minus-icon-tall", "report-plus-icon-tall"] as NSArray
            let colors = [UIColor.DarkGray, UIColor.Green, UIColor.Red]
            let sources = item[4] as! NSDictionary
            
            let actions = [] as NSMutableArray
            for i in 0..<titles.count
            {
                let title = titles[i] as! String
                let titleArray = sources.allKeys as NSArray
                if titleArray.contains(title)
                {
                    let source = sources[title] as? NSArray
                    if i == 0 || (i != 0 && source != nil && source?.count != 0)
                    {
                        if Constant.iOS11IsAvailable()
                        {
                            let contextItem = UIContextualAction(style: .normal, title: "")
                            {  (contextualAction, view, boolValue) in
                                self.pushController(type: title, source: source as AnyObject, title: item[0] as! String)
                            }
                            if #available(iOS 13.0, *) {
                                contextItem.image = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60)).image { _ in
                                    UIImage(named: images[i] as! String)?.draw(in: CGRect(x: 0, y: 0, width: 60, height: 60))
                                }
                            }
                            else
                            {
                                images = ["list-icon-white", "report-minus-icon-white", "report-plus-icon-white"]
                               
                            }
                            contextItem.image =  UIImage(named: images[i] as! String)
                            contextItem.backgroundColor = colors[i]
                            actions.add(contextItem)
                        }
                    }
                }
            }
            if Constant.iOS11IsAvailable()
            {
                let configuration = UISwipeActionsConfiguration(actions: actions as! [UIContextualAction])
                configuration.performsFirstActionWithFullSwipe = false
                return configuration
            }
        }
        return nil
    }
    
    func treeView(_ treeView: RATreeView, editingStyleForRowForItem item: Any) -> UITableViewCell.EditingStyle {
        if item is NSArray
        {
            //            let item = item as! NSArray
            return UITableViewCell.EditingStyle.delete
        }
        return .none
    }
    func pushController(type: String, source: AnyObject, title: String)
    {
        let controller = DisabledComplexReportListController(withCameraList: source, title: title)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
