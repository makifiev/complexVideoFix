//
//  MapMultipleComplexCell.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.08.2021.
//

import Foundation
import UIKit
import CoreData

class MapMultipleComplexCell: UITableViewCell
{
    var mSelectedBg: UIView!
    var mState: UIView!
    var mName: UILabel!
    var mLine: UIView!
    var mType: UILabel!
    
    var lineHidden:Bool!
    var workState: Int!
    var name: String!
    var type: String!
    
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
    
    mType = UILabel()
    mType.labelWithFrame(frame: CGRect(x: mState.x, y: mName.y + mName.frame.height + 5, width: 0, height: 14), colors: [UIColor.DarkGray, UIColor.clear])
    mType.font = Constant.setMediumFont(size: 14)
    self.contentView.addSubview(mType)
    
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
    
    func selected(_ selected: Bool, animated: Bool)
    {
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
    
    func setWorkState(workState:Int)
    {
        mState.backgroundColor = Constant.colors[workState]
    }
    func setName(type:String)
    {
        mName.text = type
        mType.sizeToFit()
    }
    
    func setType(type: String)
    {
        mType.text = type
        mType.frame.size.width = Constant.mainFrame.size.width - 50
        mType.sizeToFit()
    }
    
    func setLineHidden(lineHidden: Bool)
    {
        mLine.isHidden = true
    }
    
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
