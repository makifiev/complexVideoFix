//
//  ReportViolationTypesController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.11.2021.
//

import Foundation
import UIKit
import CoreData

class ReportViolationTypesController: UIViewController, UISearchBarDelegate, TableViewDelegate
{
    var mViolationTypes: NSDictionary!
    var mTypes: NSArray!
    var mTitle: String!
    
    var mSearchBar: UISearchBar!
    var mTable: TableView!
    var mNoDataLabel: UILabel!
    
    var mNoData: Bool = false
    
    init(withViolationTypes: NSDictionary, title: String)
    {
        super.init(nibName: nil, bundle: nil)
        if withViolationTypes is NSDictionary && (withViolationTypes as NSDictionary).allKeys.count != 0
        {
            mViolationTypes = withViolationTypes
            mTypes = self.getSortedTypes(dict: withViolationTypes, search: "")
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
    
    func getSortedTypes(dict: NSDictionary, search: String) -> NSArray
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
        
        let types: NSMutableArray = []
        
        for type in array as! [String]
        {
            
            let violationType = CoreDataStack.sharedInstance.getViolationType(id: Int(type)!)
            if  violationType?.type?.count != nil && violationType?.name?.count != nil
            {
                let string = "\(violationType?.type ?? ""). \(violationType?.name ?? "")"
                
                if ((string.lowercased().contains(search.lowercased())) != false) || search.count == 0
                {
                    types.add(type)
                }
            }
        }
        return types
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Виды нарушений"
        
        self.view = UIView(frame: Constant.mainFrame)
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = []
        
        self.addSearchBar()
        self.addTable()
    }
    
    func addSearchBar()
    {
        let panel = UIView()
        panel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        panel.backgroundColor = .white
        panel.setBlur()
        self.view.addSubview(panel)
        
        mSearchBar = UISearchBar()
        mSearchBar = mSearchBar.setSearchBarWithFrame(searchBar: mSearchBar,
                                                      frame: CGRect(x: 10, y: 5, width: panel.frame.width - 20, height: panel.frame.height - 10), textColor: UIColor.DarkGray, placeHolder: "Найти вид нарушения")
        mSearchBar.delegate = self
        panel.addSubview(mSearchBar)
        self.view.bringSubviewToFront(panel)
        let line = UIView()
        line.frame = CGRect(x: 0, y: panel.frame.origin.y + panel.frame.height, width: self.view.frame.width, height: 0.5)
        line.backgroundColor = UIColor.DarkGray
        line.alpha = 0.4
        self.view.addSubview(line)
        
        mNoDataLabel = UILabel()
        mNoDataLabel.labelWithFrame(frame: CGRect(x: 10, y: line.frame.origin.y + line.frame.height + 20, width: self.view.frame.width - 20, height: 17), colors: [UIColor.DarkGray, UIColor.clear])
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
            mTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(Constant.iPhoneNavBarCoefficient), right: 0)
            mTable.setCell(cell: ReportViolationTypeCell.self)
            mTable.setArray(array: mTypes)
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
        let cell = cell as! ReportViolationTypeCell
        let a = Int(mTypes[atIndexPath.row] as! String)
        let violationType = CoreDataStack.sharedInstance.getViolationType(id:  Int(mTypes[atIndexPath.row] as! String)!)
        
        cell.setType(type: "\(violationType?.type ?? ""). \(violationType?.name ?? "")")
        cell.setValue(value: "Всего КВФ: \(mViolationTypes[mTypes[atIndexPath.row]] ?? "Нет данных")")
        cell.setLineHidden(lineHidden: atIndexPath.row == 0)
    }
    
    func heightForRowAtIndexPath(indexPath: IndexPath) -> CGFloat {
        let violationType = CoreDataStack.sharedInstance.getViolationType(id: Int(mTypes[indexPath.row] as! String)!)
        let width = mTable.frame.width - 50
        
        let fontRect = Constant.setMediumFont(size: 17)
        let attributesRect: [NSAttributedString.Key: Any] = [.font: fontRect]
        
        let fontRect1 = Constant.setMediumFont(size: 14)
        let attributesRect1: [NSAttributedString.Key: Any] = [.font: fontRect1]
        
        let type = "\(violationType?.type ?? ""). \(violationType?.name ?? "")"
        let reasonRect = (type as NSString).boundingRect(with: CGSize(width: width, height: 0),
                                                         options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                         attributes: attributesRect,
                                                         context: nil)
        
        let value = "Всего КВФ: \(mViolationTypes[mTypes[indexPath.row]] ?? "Нет данных")"
        
        let valueRect = value.boundingRect(with: CGSize(width: width, height: 0),
                                           options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                           attributes: attributesRect1,
                                           context: nil)
        
        return reasonRect.size.height + valueRect.size.height + 25
    }
    
    func tableWillScroll() {
        self.view.endEditing(true)
    }
    
    func viewForHeaderInSection(section: Int) -> UIView {
        let header = UIView()
        header.frame.size.width = mTable.frame.width
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
    
    func heightForHeaderInSection(section: Int) -> CGFloat {
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
        
        mTypes = self.getSortedTypes(dict: mViolationTypes, search: subString)
        mTable.setArray(array: mTypes)
        mTable.update()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
