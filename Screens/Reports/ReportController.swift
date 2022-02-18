//
//  ReportController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.11.2021.
//

import Foundation
import UIKit
import CoreData

class ReportController: UIViewController, UITableViewDataSource, UITableViewDelegate, RATreeViewDelegate, RATreeViewDataSource
{
    var mReport: Report!
    var mFormattedReport: NSArray!
    var mReportTree: RATreeView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(withReport: Report)
    {
        super.init(nibName: nil, bundle: nil)
        mReport = withReport
        mFormattedReport = NSArray(array: withReport.format())
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(update), name: Notification.Name(Constant.historyReady), object: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if mReport.historyMeasure_1 == nil
        {
            let historyLoading = UIBarButtonItem().itemWithActivityIndicator(color: .Blue)
            self.navigationItem.setRightBarButton(historyLoading, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Состояние системы"
        
        self.view = UIView(frame: Constant.mainFrame)
         
        self.edgesForExtendedLayout = []
        
        self.addReportTree()
    }
    
    func addReportTree()
    {
        let backGround = UIView(frame: Constant.mainFrame)
        backGround.backgroundColor = .White
        self.view.addSubview(backGround)
        
        mReportTree = RATreeView.init()
        mReportTree.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height - Constant.topBarHeight)
        mReportTree.delegate = self
        mReportTree.dataSource = self
        mReportTree.separatorStyle = RATreeViewCellSeparatorStyleNone
        mReportTree.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(Constant.iPhoneNavBarCoefficient), right: 0)
        mReportTree.separatorStyle = RATreeViewCellSeparatorStyleSingleLineEtched
        //        mReportTree.reloadData()
        self.view.addSubview(mReportTree)
    }
    
    @objc func update(notification: Notification)
    {
        let success = (notification.userInfo)?["success"] as! Bool
        if success
        {
            if mReport.historyMeasure_1 != nil
            {
                mFormattedReport = NSArray(array: mReport.format())
                //                mReportTree.reloadData()
            }
        }
        else
        {
            let alert: UIAlertController = UIAlertController(title: "Ошибка",
                                                             message: "Ошибка формирования истории!",
                                                             preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        self.navigationItem.setRightBarButton(nil, animated: true)
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
            width = treeView.frame.width - (20 * CGFloat(level)) - 40
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
            let cell = treeView.cell(forItem: item) as! ReportCell
            cell.setArrowOpen(arrowOpen: true)
            let children = item[3] as! NSArray
            return children.count != 0
        }
        return false
    }
    
    func treeView(_ treeView: RATreeView, didExpandRowForItem item: Any) {
        if item is NSArray
        {
            let item = item as! NSArray
            let children = item[3] as! NSArray
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
            let cell = treeView.cell(forItem: item) as! ReportCell
            cell.setArrowOpen(arrowOpen: false)
            
            let children = item[3] as! NSArray
            return children.count != 0
        }
        return false
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell
    {
        var cell = treeView.dequeueReusableCell(withIdentifier: NSStringFromClass(ReportCell.self)) as? ReportCell
        if cell == nil
        {
            cell = ReportCell.init(style: .subtitle, reuseIdentifier: NSStringFromClass(ReportCell.self))
            cell!.selectionStyle = .none
        }
        if item is NSArray
        {
            let item = item as! NSArray
            let level = treeView.levelForCell(forItem: item)
            let children = item[3] as! NSArray
            
            cell!.setArrowHidden(arrowIsHidden: children.count == 0)
            cell!.setArrowOpen(arrowOpen: treeView.isCell(forItemExpanded: item))
            cell!.setLevel(level: level)
            cell!.setTitle(title: item[0] as! String)
            cell!.setValue(value: item[1] as! Int)
            
            cell!.setlineHidden(lineHidden: false)
        }
        else
        {
            cell!.setSection(section: "\(item ?? "")")
            cell!.setlineHidden(lineHidden: true)
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
            let children = item[3] as! NSArray
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
        let children = item[3] as! NSArray
        return children[index]
    }
    
    
    func treeView(_ treeView: RATreeView, trailingSwipeActionsConfigurationForItem item: Any) -> UISwipeActionsConfiguration? {
        if item is NSArray
        {
            let item = item as! NSArray
            let titles = ["Список КВФ", "История", "Виды нарушений", "Причины отказа"] as NSArray
            let images = ["list-icon-white", "history-trend-icon-white", "violation-icon-white", "reject-icon-white"] as NSArray
            let colors = [UIColor.DarkGray, UIColor.Blue, UIColor.Purple, UIColor.Orange]
            let sources = item[2] as! NSDictionary
             
            
            let actions = [] as NSMutableArray
            for i in 0..<titles.count
            {
                let title = titles[i] as! String
                let titleArray = sources.allKeys as NSArray
                if titleArray.contains(title)
                {
                  
                    if titles[i] as! String == "История" && mReport.historyMeasure_1 == nil
                    {
                        continue
                    }
                    if Constant.iOS11IsAvailable()
                    {
                        let contextItem = UIContextualAction(style: .normal, title: "")
                        {  (contextualAction, view, boolValue) in
                            
                            self.pushController(type: titles[i] as! String, source: sources[titles[i]] as AnyObject, title: item[0] as! String)
                        }
                        contextItem.image = UIImage(named: images[i] as! String)
                        contextItem.backgroundColor = colors[i]
                        actions.add(contextItem)
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
            return UITableViewCell.EditingStyle.delete
        }
        return .none
    }
    
    func pushController(type: String, source: AnyObject, title: String)
    {
        var controller: UIViewController!
        if type == "Список КВФ"
        {
            controller = ReportComplexListController(withComplexList: source, title: title)
        }
        else if type == "История"
        {
            controller = ReportHistoryController(withHistory: source as? NSDictionary ?? [:], title: title)
        }
        else if type == "Виды нарушений"
        {
            controller = ReportViolationTypesController(withViolationTypes: source as? NSDictionary ?? [:], title: title)
        }
        else if type == "Причины отказа"
        {
            controller = ReportRefuseReasonsController(withRefuseReasons: source, title: title)
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}



extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}



