//
//  ReportRefuseReasonsController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.11.2021.
//

import Foundation
import UIKit
import CoreData

class ReportRefuseReasonsController: UIViewController, UISearchBarDelegate, TableViewDelegate
{
    var mRefuseReasons: NSDictionary!
    var mReasons: NSArray!
    var mTitle: String!
    var mSearchBar: UISearchBar!
    var mTable: TableView!
    var mNoDataLabel: UILabel!
    
    var mNoData:Bool = false
    
    init(withRefuseReasons: Any, title: String)
    {
        super.init(nibName: nil, bundle: nil)
        if withRefuseReasons is NSDictionary && (withRefuseReasons as! NSDictionary).allKeys.count != 0
        {
            mRefuseReasons = withRefuseReasons as? NSDictionary
            mReasons = self.getSortedReasons(dict: withRefuseReasons as! NSDictionary, search: "")
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
    
    func getSortedReasons(dict: NSDictionary, search: String) -> NSArray
    {
        let array:NSArray = dict.keysSortedByValue
        { (obj1, obj2) -> ComparisonResult in
            
            
            if (obj1 as! Int) < (obj2 as! Int)
            {
                return ComparisonResult.orderedDescending
            }
            
            if  (obj1 as! Int) > (obj2 as! Int)
            {
                return ComparisonResult.orderedAscending
            }
            return ComparisonResult.orderedSame
        } as NSArray
        
        let reasons: NSMutableArray = []
        for string in array as! [String]
        {
            let reason = Int(string)
            let refuseReason = CoreDataStack.sharedInstance.getRefuseReason(id: Int(reason!))
        
            if ((refuseReason?.reason?.lowercased().contains(search.lowercased())) != false) || search.count == 0
            {
                reasons.add(reason!)
            }
        }
        return reasons
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Причины отказа"
        self.view.backgroundColor = .White
        self.edgesForExtendedLayout = []
        self.navigationController!.navigationBar.isTranslucent = true
        self.addSearchBar()
        self.addTable()
    }
    
    func addSearchBar()
    {
        let panel = UIView()
        panel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        panel.backgroundColor = .White
        panel.setBlur()
        self.view.addSubview(panel)
        
        mSearchBar = UISearchBar()
        mSearchBar = mSearchBar.setSearchBarWithFrame(searchBar: mSearchBar, frame: CGRect(x: 10, y: 5, width: panel.frame.width - 20, height: panel.frame.height - 10), textColor: .DarkGray, placeHolder: "Найти причину отказа")
        mSearchBar.delegate = self
        panel.addSubview(mSearchBar)
        
        let line = UIView()
        line.frame = CGRect(x: 0, y: panel.frame.origin.y + panel.frame.height, width: self.view.frame.width, height: 0.5)
        line.backgroundColor = UIColor.DarkGray
        line.alpha = 0.4
        self.view.addSubview(line)
        self.view.bringSubviewToFront(panel)
        mNoDataLabel = UILabel()
        mNoDataLabel.labelWithFrame(frame: CGRect(x: 10, y: line.frame.origin.y +  line.frame.height + 20, width: self.view.frame.width - 20, height: 17), colors: [UIColor.DarkGray, UIColor.clear])
        mNoDataLabel.textAlignment = .center
        mNoDataLabel.font = Constant.setMediumFont(size: 17)
        mNoDataLabel.text = "Нет данных"
        mNoDataLabel.isHidden = true
        self.view.addSubview(mNoDataLabel)
    }
    
    func addTable()
    {
       if !mNoData
       {
        mTable = TableView(withStyle: .grouped)
        mTable.frame = CGRect(x: 0, y: mNoDataLabel.frame.origin.y - 55, width: self.view.frame.width, height: self.view.frame.height - (mNoDataLabel.frame.origin.y - 55) - Constant.topBarHeight)
        mTable.mTableViewDelegate = self
        mTable.setCell(cell: ReportRefuseReasonCell.self)
 
        mTable.setArray(array: mReasons)
        mTable.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(mTable)
        self.view.sendSubviewToBack(mTable)
       }
        else
       {
        mNoDataLabel.isHidden = false
        mSearchBar.isHidden = true
       }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath: IndexPath) {
        let cell = cell as! ReportRefuseReasonCell
        let refuseReason = CoreDataStack.sharedInstance.getRefuseReason(id: mReasons[atIndexPath.row] as! Int)
        
        cell.setType(type: refuseReason?.reason ?? "")
        cell.setValue(value: "Всего отказано: \(mRefuseReasons["\(mReasons[atIndexPath.row])"] ?? "Нет данных")")
        cell.setLineHidden(lineHidden: atIndexPath.row == 0)
    }
    
    func heightForRowAtIndexPath(indexPath: IndexPath) -> CGFloat {
        let refuseReason = CoreDataStack.sharedInstance.getRefuseReason(id: mReasons[indexPath.row] as! Int)
        let width = mTable.frame.width - 50
         
        let fontRect = Constant.setMediumFont(size: 17)
        let attributesRect: [NSAttributedString.Key: Any] = [.font: fontRect]
        
        let fontRect1 = Constant.setMediumFont(size: 14)
        let attributesRect1: [NSAttributedString.Key: Any] = [.font: fontRect1]
        
        let reasonRect = ((refuseReason?.reason?.uppercased())! as NSString).boundingRect(with: CGSize(width: width, height: 0),
                                                                  options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                  attributes: attributesRect,
                                                                  context: nil)
        
        let value = "Всего отказано: \(mRefuseReasons[mReasons[indexPath.row]])"
        let valueRect = value.boundingRect(with: CGSize(width: width, height: 0),
                                           options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                           attributes: attributesRect1,
                                           context: nil)
        
        return reasonRect.size.height + valueRect.size.height + 25
    }
    
    func tableWillScroll()
    {
        self.view.endEditing(true)
    }
    
    func viewForHeaderInSection(section: Int) -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: mTable.frame.width, height: 0))
        
        header.backgroundColor = UIColor.GrayApha
        
        let title = UILabel()
        title.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        
        title.text = mTitle.uppercased()
        title.font = Constant.setMediumFont(size: 12)
        title.frame.size.width = mTable.frame.width - 20
        title.sizeToFit()
        header.addSubview(title)
        
        header.frame.size.height = title.frame.height + 26
         
        title.setPosition = CGPoint(x: 10, y: header.frame.height - title.frame.height - 6)
        
        return header
    }
    
    func heightForHeaderInSection(section: Int) -> CGFloat
    {
        let fontRect = Constant.setMediumFont(size: 12)
        let attributesRect: [NSAttributedString.Key: Any] = [.font: fontRect]
        
        let rect = (mTitle.uppercased()).boundingRect(with: CGSize(width: mTable.frame.width - 20, height: 0),
                                           options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                           attributes: attributesRect,
                                           context: nil)
        
        return rect.size.height + 26
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let subString = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        subString.stringWithoutDoubleSpaces()
        
        mReasons = self.getSortedReasons(dict: mRefuseReasons, search: subString)
        mTable.setArray(array: mReasons)
        mTable.update()
   
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
