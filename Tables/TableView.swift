//
//  UITableViewExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 22.08.2021.
//

import Foundation
import UIKit
import CoreData

enum TableViewMode: Int
{
    case TableViewModeSourceArray = 0
    case TableViewModeSourceDictionary = 1
    case TableViewModeSourceController = 2
}

@objc protocol TableViewDelegate: class
{
    func configureCell(cell: UITableViewCell, atIndexPath: IndexPath)
    
    @objc optional func selectedCell(cell:UITableViewCell, atIndexPath: IndexPath)
    @objc optional func heightForRowAtIndexPath(indexPath: IndexPath) -> CGFloat
    @objc optional func viewForHeaderInSection(section: Int) -> UIView
    @objc optional func heightForHeaderInSection(section: Int) -> CGFloat
    @objc optional func tableWillScroll()
    @objc optional func willDisplay(cell: UITableViewCell, indexPath: IndexPath)
}

class TableView : UITableView, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate
{
    
    var mCell: AnyClass!
    var mController: NSFetchedResultsController<NSFetchRequestResult>!
    var mArray: NSArray!
    var mDict: NSDictionary!
    var mAscending: Bool!
    var mMode: TableViewMode!
    weak var mTableViewDelegate: TableViewDelegate?
    var blockOperations: [BlockOperation] = []
    
    init(withStyle: UITableView.Style) {
        super.init(frame: CGRect.zero, style: withStyle)
        
        self.backgroundColor = .clear
        self.separatorStyle = .none
        self.separatorInset = .zero
        
        if withStyle == UITableView.Style.grouped
        {
            self.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0))
            self.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0))
        }
        if Constant.iOS11IsAvailable()
        {
            self.contentInsetAdjustmentBehavior = .never
            self.estimatedRowHeight = 0
            self.estimatedSectionHeaderHeight = 0
            self.estimatedSectionFooterHeight = 0
        }
    }
    
    func setCell(cell: AnyClass)
    {
        mCell = cell
    }
    
    func update()
    {
        self.reloadData()
    }
    
    func setFetchController(controller: NSFetchedResultsController<NSFetchRequestResult>, withDelegate:Bool)
    {
        mController = controller
        mMode = TableViewMode.TableViewModeSourceController
        if withDelegate
        {
            mController.delegate = self
        }
        self.delegate = self
        self.dataSource = self
    }
    
    func setArray(array:NSArray)
    {
        mArray = array
        mMode = TableViewMode.TableViewModeSourceArray
        self.delegate = self
        self.dataSource = self
    }
    
    func setDictionary(dictionary: NSDictionary, ascending: Bool)
    {
        mDict = dictionary
        mAscending = ascending
        mMode = TableViewMode.TableViewModeSourceDictionary
        self.delegate = self
        self.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if mMode == TableViewMode.TableViewModeSourceDictionary
        {
            return mDict.allKeys.count
        }
        else if mMode == TableViewMode.TableViewModeSourceArray
        {
            return 1
        }
        return mController.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mMode == TableViewMode.TableViewModeSourceArray
        {
            return mArray.count
        }
        return self.getNumberInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if mTableViewDelegate?.viewForHeaderInSection != nil
        {
            if mTableViewDelegate?.heightForHeaderInSection != nil
            {
                return CGFloat((mTableViewDelegate?.heightForHeaderInSection!(section: section))!)
            }
            else
            {
                return 34
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if mTableViewDelegate?.viewForHeaderInSection != nil
        {
            if mMode == TableViewMode.TableViewModeSourceDictionary
            {
                if section == mDict.allKeys.count
                {
                    let view = UIView()
                    view.alpha = 0
                    return view
                }
            }
            else if mMode == TableViewMode.TableViewModeSourceController
            {
                if section == mController.sections?.count
                {
                    let view = UIView()
                    view.alpha = 0
                    return view
                }
                let view = mTableViewDelegate!.viewForHeaderInSection!(section: section)
                let header = UIView()
                header.addSubview(view)
                return header
            }
            return mTableViewDelegate?.viewForHeaderInSection!(section: section)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if mTableViewDelegate?.heightForRowAtIndexPath != nil
        {
            return mTableViewDelegate!.heightForRowAtIndexPath!(indexPath: indexPath)
        }
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(mCell))
        let mcell = mCell as! UITableViewCell.Type
        if cell == nil
        {
            print(NSStringFromClass(mCell))
            cell = mcell.init(style: .subtitle, reuseIdentifier: NSStringFromClass(mCell))
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            if mTableViewDelegate?.selectedCell != nil
            {
                
            }
        }
        mTableViewDelegate?.configureCell(cell: cell!, atIndexPath: indexPath)
        return cell!
    }
    
    @objc func longpress(longPress: UILongPressGestureRecognizer, indexPath: IndexPath)
    {

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = self.cellForRow(at: indexPath)!
        if mTableViewDelegate?.selectedCell != nil
        {
            mTableViewDelegate?.selectedCell!(cell: cell, atIndexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if mTableViewDelegate?.willDisplay != nil
        {
            mTableViewDelegate?.willDisplay?(cell: cell, indexPath: indexPath)
        }
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 10, height: 10)
        cell.alpha = 0.5
        UIView.animate(withDuration: 0.2, animations: {
            cell.alpha = 1
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        }, completion: nil)
    }
    
    func stopScrolling()
    {
        self.setContentOffset(self.contentOffset, animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if ((mTableViewDelegate?.tableWillScroll) != nil)
        {
            mTableViewDelegate?.tableWillScroll!()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.beginUpdates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getNumberInSection(section: Int) -> Int
    {
        if mMode == TableViewMode.TableViewModeSourceDictionary
        {
            var keys:NSArray = mDict.allKeys as NSArray
            keys = keys.sortedArray(using: #selector(NSString.localizedCaseInsensitiveCompare(_:))) as NSArray
            
            if !mAscending
            {
                keys = keys.reverseObjectEnumerator().allObjects as NSArray
            }
            
            let array: NSArray = mDict[keys[section]] as! NSArray
            return array.count
        }
        else
        {
            let sectionInfo:NSFetchedResultsSectionInfo = mController.sections![section]
            return sectionInfo.numberOfObjects
        }
        
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            let op2 = BlockOperation{ [weak self] in self?.insertRows(at: [newIndexPath!], with: .fade)}
            blockOperations.append(op2)
            break
            
        case .delete:
            guard let indexPath = indexPath else { return }
            let op = BlockOperation { [weak self] in self?.deleteRows(at: [indexPath], with: .fade) }
            blockOperations.append(op)
            
            break
            
        case .update:
            guard let indexPath = indexPath else { return }
            mTableViewDelegate?.configureCell(cell: self.cellForRow(at: indexPath)!, atIndexPath: indexPath)
            break
        case .move:
            guard let indexPath = indexPath else { return }
            self.deleteRows(at: [indexPath], with: .fade)
            self.insertRows(at: [indexPath], with: .fade)
            break
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch (type) {
        case .insert:
            self.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            break
        case .delete:
            self.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.endUpdates()
        self.update()
    }
    
}
