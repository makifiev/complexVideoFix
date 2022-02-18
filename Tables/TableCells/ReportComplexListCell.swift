//
//  ReportComplexListCell.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 14.11.2021.
//

import Foundation
import UIKit

class ReportComplexListCell: UITableViewCell
{
    
    var mSelectedBg: UIView!
    var mLine: UIView!
    var mAddress: UILabel!
    var mInformation: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
      {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
        mSelectedBg = UIView()
        mSelectedBg.backgroundColor = UIColor.BlackAlpha
        mSelectedBg.isHidden = true
        mSelectedBg.alpha = 0
        self.contentView.addSubview(mSelectedBg)
        
        mAddress = UILabel()
        mAddress.labelWithFrame(frame: CGRect.zero, colors: [UIColor.Blue, UIColor.clear])
        mAddress.setPosition = CGPoint(x: 10, y: 10)
        mAddress.font = Constant.setMediumFont(size: 17)
        self.contentView.addSubview(mAddress)
        
        mInformation = UILabel()
        mInformation.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        mInformation.frame.origin.x = mAddress.frame.origin.x
        mInformation.font = Constant.setMediumFont(size: 14)
        self.contentView.addSubview(mInformation)
        
        mLine = UIView()
        mLine.frame.size = CGSize(width: Constant.mainFrame.size.width, height: 0.5)
        mLine.alpha = 0.3
        mLine.backgroundColor = UIColor.DarkGray
        self.addSubview(mLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isCellSelected() -> Bool
    {
        return !mSelectedBg.isHidden
    }
    
    func selected(selected: Bool, animated: Bool)
    {
        mSelectedBg.frame.size = self.frame.size
        if selected
        {
            mSelectedBg.isHidden = false
        }
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.mSelectedBg.alpha = selected ? 1 : 0
        } completion: { (f: Bool) in
            if !selected
            {
                self.mSelectedBg.isHidden = true
            }
        }
    }
    
    func setAddress(address: String)
    {
        mAddress.text = address
        mAddress.frame.size.width = Constant.mainFrame.size.width - 50
        mAddress.sizeToFit()
    }
    
    func setInformation(information: String)
    {
        mInformation.text = information
        mInformation.frame.origin.y = mAddress.frame.origin.y + mAddress.frame.height + 5
        mInformation.frame.size.width = Constant.mainFrame.size.width - 50
        mInformation.sizeToFit()
    }
    
    func setLineHidden(lineHidden: Bool)
    {
        mLine.isHidden = lineHidden
    }
}
