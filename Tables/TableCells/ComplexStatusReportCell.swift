//
//  ComplexStatusReportCell.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 23.10.2021.
//


import Foundation
import UIKit
import CoreData

class ComplexStatusReportCell: UITableViewCell
{
    var view: UIView!
    var mState: UIImageView!
    var mTitle: UILabel!
    var mValue: UILabel!
    var mValueDiff: UILabel!
    
    var mLine: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCell()
        
    }
    
    func setCell()
    {
//        self.contentView.frame = self.view.frame
        view = UIView()
        view.frame = self.contentView.frame
//        view.backgroundColor = .purple
        self.contentView.addSubview(view)
        
        
        mState = UIImageView()
        mState.frame = CGRect(x: 10, y: 20, width: 22, height: 22)
        mState.contentMode = .scaleAspectFit
        
        self.view.addSubview(mState)
        
        
        
        mTitle = UILabel()
        
        mTitle.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        mTitle.setPosition = CGPoint(x: 42, y: 10)
        mTitle.font = Constant.setMediumFont(size: 14)
        self.view.addSubview(mTitle)
        
        mValue = UILabel()
        mValue.labelWithFrame(frame: .zero, colors: [UIColor.Blue, UIColor.clear])
        mValue.font = Constant.setMediumFont(size: 17)
        self.view.addSubview(mValue)
        
        mValueDiff = UILabel()
        mValueDiff.labelWithFrame(frame: .zero, colors: [UIColor.clear, UIColor.clear])
        mValueDiff.font = Constant.setMediumFont(size: 17)
        self.view.addSubview(mValueDiff)
        
        mLine = UIView()
        mLine.frame.size = CGSize(width: Constant.mainFrame.size.width, height: 0.5)
        mLine.alpha = 0.3
        mLine.backgroundColor = UIColor.DarkGray
        self.view.addSubview(mLine)
    }
    
    func setTitle(title: String)
    {
        mTitle.text = title
        mTitle.frame.size.width = Constant.mainFrame.size.width - 10
        mTitle.sizeToFit()
    }
    
    func setValue(value: Int)
    {
        mValue.text = "\(value)"
        mValue.frame.size.width = Constant.mainFrame.size.width - 20
        
        mValue.sizeToFit()
        mValue.setPosition = CGPoint(x: mTitle.frame.origin.x, y: mTitle.frame.origin.y + mTitle.frame.height + 5)
    }
    func setValueDiff(valueDiff: Int)
    {
        let symbol = self.processDiff(diff: valueDiff, label: mValueDiff)
        mValueDiff.text = "\(valueDiff) \(symbol)"
        mValueDiff.frame.size.width = Constant.mainFrame.size.width - 20
        mValueDiff.sizeToFit()
        mValueDiff.frame.origin.x = Constant.mainFrame.size.width - mValueDiff.frame.width - 7
        mValueDiff.center.y = mValue.frame.origin.y
        
        mState.center.y = mValueDiff.center.y
    }
    
    func processDiff(diff: Int, label: UILabel) -> String
    {
        var symbol = ""
        if diff < 0
        {
            symbol = "▼"
            label.textColor = .Red
            mState.image = UIImage(named: "list-exclamation-orange")
        }
        else if diff > 0
        {
            symbol = "▲"
            label.textColor = .Green
            mState.image = UIImage(named: "list-checkbox-green")
        }
        else
        {
            symbol = "—"
            label.textColor = .Purple
            mState.image = UIImage(named: "list-checkbox-green")
        }
        return symbol
    }
    
    var lineHidden: Bool
    {
        get
        {
            return true
        }
        set
        {
            mLine.isHidden = newValue
        }
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
