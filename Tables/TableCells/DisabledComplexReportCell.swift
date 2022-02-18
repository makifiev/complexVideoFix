//
//  DisabledComplexreportCell.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 26.10.2021.
//

import Foundation
import UIKit

class DisabledComplexReportCell: ReportCell
{
    var mPlus: UILabel!
    var mMinus: UILabel!
    var mDiff: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
      {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
        mPlus = UILabel()
        mPlus.labelWithFrame(frame: CGRect.zero, colors: [UIColor.clear, UIColor.clear])
        mPlus.font = Constant.setMediumFont(size: 17)
        self.contentView.addSubview(mPlus)
        
        mMinus = UILabel()
        mMinus.labelWithFrame(frame: CGRect.zero, colors: [UIColor.clear, UIColor.clear])
        mMinus.font = Constant.setMediumFont(size: 17)
        self.addSubview(mMinus)
        
        mDiff = UILabel()
        mDiff.labelWithFrame(frame: CGRect.zero, colors: [UIColor.clear, UIColor.clear])
        mDiff.font = Constant.setMediumFont(size: 17)
        self.addSubview(mDiff)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    
    func setPlusMinusHidden(plusMinusHidden: Bool)
    {
        mPlus.isHidden = plusMinusHidden
        mMinus.isHidden = plusMinusHidden
        mDiff.isHidden = plusMinusHidden
    }
    
    func setMinus(minus: Int)
    {
        if minus == 0
        {
            mMinus.text = " 0"
            mMinus.textColor = UIColor.Purple
        }
        else
        {
            mMinus.text = "-\(minus)"
            mMinus.textColor = UIColor.Green
        }
        mMinus.frame.size.width = Constant.mainFrame.size.width - 20
        mMinus.sizeToFit()
    }
    
    func setPlus(plus: Int)
    {
        if plus == 0
        {
            mPlus.text = " 0"
            mPlus.textColor = UIColor.Purple
        }
        else
        {
            mPlus.text = "+\(plus)"
            mPlus.textColor = UIColor.Red
        }
        mPlus.frame.size.width = Constant.mainFrame.size.width - 20
        mPlus.sizeToFit()
        
        self.updateDiff()
    }
    
    func updateDiff()
    {
        let plus = Int(mPlus.text ?? "") ?? 0
        let minus = Int(mMinus.text ?? "") ?? 0
        
        self.processDiff(diff: plus + minus, label: mDiff)
        mDiff.frame.size.width = Constant.mainFrame.size.width - 20
        mDiff.sizeToFit()
        mDiff.frame.origin.x = Constant.mainFrame.size.width - mDiff.frame.width - 8
        
        mMinus.frame.origin.x = mDiff.frame.origin.x - mMinus.frame.width - 15
        mPlus.frame.origin.x = mMinus.frame.origin.x - mPlus.frame.width - 15
        
        mTitle.frame.size.width = Constant.mainFrame.size.width - (mArrow.frame.width + 10) - 120
        mTitle.sizeToFit()
        mTitle.setPosition = CGPoint(x: mArrow.frame.origin.x + mArrow.frame.width + 10, y: 10)
        
        mValue.setPosition = CGPoint(x: mTitle.frame.origin.x, y: mTitle.frame.origin.y + mTitle.frame.height + 5)
        
        mMinus.center.y = (mValue.frame.origin.y + mValue.frame.height + 10) / 2
        mPlus.center.y = mMinus.center.y
        mDiff.center.y = mPlus.center.y
    }
    
    func processDiff(diff: Int, label: UILabel)
    {
        if diff < 0
        {
            label.text = "▼"
            label.textColor = .Green
        }
        else if diff > 0
        {
            label.text = "▲"
            label.textColor = .Red
        }
        else
        {
            label.text = "—"
            label.textColor = .Purple
        }
    }
}
