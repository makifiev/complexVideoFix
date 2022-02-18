//
//  DisabledComplexReportListController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 14.11.2021.
//

import Foundation
import UIKit
import CoreData


class DisabledComplexReportListController: UIViewController, TableViewDelegate, UISearchBarDelegate
{
    var mCameraList: NSArray!
    var mTitle: String!
    var mNoDataLabel: UILabel!
    var mController: NSFetchedResultsController<NSFetchRequestResult>!
    var mSearchBar: UISearchBar!
    var mTable: TableView!
    
    var mComplexShowed: Bool!
    var mNoData: Bool = false
    
    init(withCameraList:AnyObject, title: String)
    {
        super.init(nibName: nil, bundle: nil)
        if withCameraList is NSArray && (withCameraList as! NSArray).count != 0
        {
            mCameraList = withCameraList as? NSArray
        }
        else
        {
            mNoData = true
        }
        mTitle = title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
        } completion: { (f: Bool) in
            self.mComplexShowed = false
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if mComplexShowed
        {
            UIView.animate(withDuration: 0.3) {
                self.view.alpha = 0
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Список КВФ"
        
        self.view = UIView()
        self.view.frame = Constant.mainFrame
        self.view.backgroundColor = UIColor.White
        self.edgesForExtendedLayout = []
        
        self.addSearchBar()
        self.addTable()
    }
    
    func addSearchBar()
    {
        let panel = UIView()
        panel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        panel.backgroundColor = .White
        self.view.addSubview(panel)
        
        mSearchBar = UISearchBar()
        mSearchBar = mSearchBar.setSearchBarWithFrame(searchBar: mSearchBar, frame: CGRect(x: 10, y: 5, width: panel.frame.width - 20, height: panel.frame.height - 10), textColor: UIColor.DarkGray, placeHolder: "Найти КВФ по номеру или адресу")
        
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
            mController = CoreDataStack.sharedInstance.getComplexesByNameOrAddressInIdsForDisable(nameOrAddress: "", byCameras: mCameraList)
            mTable = TableView.init(withStyle: .grouped)
            mTable.frame = CGRect(x: 0, y: mNoDataLabel.frame.origin.y - 55, width: self.view.frame.width, height: self.view.frame.height - (mNoDataLabel.frame.origin.y - 55) - Constant.topBarHeight)
            mTable.mTableViewDelegate = self
            mTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(Constant.iPhoneNavBarCoefficient), right: 0)
            mTable.setCell(cell: ReportComplexListCell.self)
            mTable.setFetchController(controller: mController, withDelegate: false)
           
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
        let cell = cell as! ReportComplexListCell
        let complex = mController.object(at: atIndexPath) as! Complex
        cell.selected(selected: false, animated: false)
        cell.setAddress(address: complex.placeName ?? "")
        cell.setInformation(information: "ID: \(complex.name ?? ""), Тип: \(complex.typeName ?? ""), Класс: \(complex.clName ?? ""), Дни: \(complex.workerDays)")
        cell.setLineHidden(lineHidden: atIndexPath.row == 0)
    }
    
    func selectedCell(cell: UITableViewCell, atIndexPath: IndexPath) {
        let cell = cell as! ReportComplexListCell
        let complex = mController.object(at: atIndexPath) as! Complex
        cell.selected(selected: true, animated: true)
        self.pushComplexController(complex:complex)
    }
    
    func heightForRowAtIndexPath(indexPath: IndexPath) -> CGFloat {
        let complex = mController.object(at: indexPath) as! Complex
        let width = mTable.frame.width - 50
        let fontRect = Constant.setMediumFont(size: 17)
        let attributesRect: [NSAttributedString.Key: Any] = [.font: fontRect]
        let fontRect1 = Constant.setMediumFont(size: 14)
        let attributesRect1: [NSAttributedString.Key: Any] = [.font: fontRect1]
        let addressRect = ((complex.placeName ?? "") as NSString).boundingRect(with: CGSize(width: width, height: 0),
                                                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                        attributes: attributesRect,
                                                                        context: nil)
         let information = "ID: \(complex.name ?? ""), Тип: \(complex.typeName ?? ""), Класс: \(complex.clName ?? ""), Дни: \(complex.workerDays)"
        let informationRect = (information as NSString).boundingRect(with: CGSize(width: width, height: 0),
                                                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                        attributes: attributesRect1,
                                                                        context: nil)
        return addressRect.size.height + informationRect.size.height + 25
    }
    
    func tableWillScroll()
    {
        self.view.endEditing(true)
    }
    
    func viewForHeaderInSection(section: Int) -> UIView
    {
        let header = UIView()
        header.frame.size.width = mTable.frame.width
        header.backgroundColor = .GrayApha
        
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
        let fontRect = Constant.setMediumFont(size: 17)
        let attributesRect: [NSAttributedString.Key: Any] = [.font: fontRect]
        
        let rect = (mTitle.uppercased() as NSString).boundingRect(with: CGSize(width: mTable.frame.width - 20, height: 0),
                                                                  options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                  attributes: attributesRect,
                                                                  context: nil)
        return rect.size.height + 26
    }
    
    func pushComplexController(complex: Complex)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let mapController = appDelegate.mapController
        
        if complex.lat != 0
        {
            mapController?.complexWillShow(complex: complex, animated: false)
        }
        let complexController = ComplexController(withComplex: complex)
        complexController.mDelegate = mapController
        self.navigationController?.pushViewController(complexController, animated: true)
        mComplexShowed = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let subString = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        subString.stringWithoutDoubleSpaces()
        mController = CoreDataStack.sharedInstance.getComplexesByNameOrAddressInIdsForDisable(nameOrAddress: subString, byCameras: mCameraList)
        mTable.setFetchController(controller: mController, withDelegate: false)
        mTable.update()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
