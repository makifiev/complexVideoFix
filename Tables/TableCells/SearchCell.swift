//
//  SearchCell.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 24.08.2021.
//

import Foundation
import UIKit
import CoreData

class SearchCell: UITableViewCell
{
    var mSelectedBg: UIView!
    var mState: UIView!
    var mName: UILabel!
    var mLine: UIView!
    var mAddress: UILabel!
    
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
      {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
          setCell()
          
      }
    
    func setCell()
    {
        mSelectedBg = UIView()
        mSelectedBg.backgroundColor = UIColor.BlackAlpha
        mSelectedBg.isHidden = true
        mSelectedBg.alpha = 0
        self.contentView.addSubview(mSelectedBg)
        
        mState = UIView()
        mState.frame = CGRect(x: 10, y: 15, width: 10, height: 10)
        mState.layer.cornerRadius = mState.frame.width / 2
        self.contentView.addSubview(mState)
        
        mName = UILabel()
        mName.labelWithFrame(frame: CGRect(x: mState.frame.origin.x + mState.frame.width + 8, y: 0, width: Constant.mainFrame.size.width + 30, height: 17), colors: [UIColor.Blue, UIColor.clear])
        mName.center.y = mState.center.y
        mName.font = Constant.setMediumFont(size: 17)
        self.contentView.addSubview(mName)
        
        mAddress = UILabel()
        mAddress.labelWithFrame(frame: CGRect(x: mState.x, y: mName.y + mName.frame.height + 5, width: 0, height: 14), colors: [UIColor.DarkGray, UIColor.clear])
        mAddress.font = Constant.setMediumFont(size: 14)
        self.contentView.addSubview(mAddress)
        
        mLine = UIView()
        mLine.frame.size = CGSize(width: Constant.mainFrame.size.width, height: 0.5)
        mLine.alpha = 0.3
        mLine.backgroundColor = UIColor.DarkGray
        self.contentView.addSubview(mLine)
    }
    
    func isCellSelected() -> Bool
    {
        return !mSelectedBg.isHidden
    }
    
     func selected(_ selected: Bool, animated: Bool) {
        mSelectedBg.frame.size = self.frame.size
        if selected
        {
            mSelectedBg.isHidden = false
        }
        UIView.animate(withDuration: animated ? 0.3 : 0, animations:
                        {
                            self.mSelectedBg.alpha = selected ? 0 : 1
                        }) { _ in
            if !selected
            {
                self.mSelectedBg.isHidden = true
            }
        }
    }
    
    var workState: Int
    {
        get
        {
            return 0
        }
        set
        {
            mState.backgroundColor = Constant.colors[newValue]
        }
    }
    
    var name: String
    {
        get
        {
            return ""
        }
        set
        {
            mName.text = newValue
        }
    }
    
    var address: String
    {
        get
        {
            return ""
        }
        set
        {
            mAddress.text = newValue
            mAddress.frame.size.width = Constant.mainFrame.size.width - 50
            mAddress.sizeToFit()
        }
       
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
    
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
}
