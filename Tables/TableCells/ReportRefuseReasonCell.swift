//
//  ReportRefuseReasonCell.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 15.11.2021.
//

import Foundation
import UIKit

class ReportRefuseReasonCell: UITableViewCell
{
    var mLine: UIView!
    var mType: UILabel!
    var mValue: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
      {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
         mType = UILabel()
        mType.labelWithFrame(frame: .zero, colors: [UIColor.Blue, UIColor.clear])
        mType.setPosition = CGPoint(x: 10, y: 10)
        mType.font = Constant.setMediumFont(size: 17)
        self.contentView.addSubview(mType)
        
        mValue = UILabel()
        mValue.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        mValue.frame.origin.x = mType.frame.origin.x
        mValue.font = Constant.setMediumFont(size: 14)
        self.contentView.addSubview(mValue)
        
        mLine = UIView()
        mLine.frame.size = CGSize(width: Constant.mainFrame.size.width, height: 0.5)
        mLine.alpha = 0.3
        mLine.backgroundColor = UIColor.DarkGray
        self.contentView.addSubview(mLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setType(type: String)
    {
        mType.text = type
        mType.frame.size.width = Constant.mainFrame.size.width - 50
        mType.sizeToFit()
    }
    
    func setValue(value: String)
    {
        mValue.text = value
        mValue.frame.origin.y = mType.frame.origin.y + mType.frame.height + 5
        mValue.frame.size.width = Constant.mainFrame.size.width - 20
        mValue.sizeToFit()
    }
    
    func setLineHidden(lineHidden: Bool)
    {
        mLine.isHidden = lineHidden
    }
    
}
