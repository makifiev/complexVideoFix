//
//  ReportCell.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 26.10.2021.
//

import Foundation
import UIKit

class ReportCell: UITableViewCell
{
    var mArrow: UIImageView!
    var mTitle: UILabel!
    var mValue: UILabel!
    var mSection: UIView!
    var mSectionTitle: UILabel!
    var mLine: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
      {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
        mArrow = UIImageView(image: UIImage(named: "tree-toggle-icon"))
        mArrow.setPosition = CGPoint(x: 0, y: 15)
        self.contentView.addSubview(mArrow)
        
        mTitle = UILabel()
        mTitle.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        mTitle.font = Constant.setMediumFont(size: 14)
        self.contentView.addSubview(mTitle)
        
        mValue = UILabel()
        mValue.labelWithFrame(frame: .zero, colors: [UIColor.Blue, UIColor.clear])
        mValue.font = Constant.setMediumFont(size: 17)
        self.contentView.addSubview(mValue)
        
        mLine = UIView()
        mLine.frame.size = CGSize(width: Constant.mainFrame.size.width, height: 0.5)
        mLine.alpha = 0.3
        mLine.backgroundColor = UIColor.DarkGray
        self.contentView.addSubview(mLine)
        
        mSection = UIView()
        mSection.frame.size.width = Constant.mainFrame.size.width
        mSection.backgroundColor = .GrayApha
        mSection.isHidden = true
        self.contentView.addSubview(mSection)
        
        mSectionTitle = UILabel()
        mSectionTitle.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        mSectionTitle.font = Constant.setMediumFont(size: 12)
        mSection.addSubview(mSectionTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setArrowHidden(arrowIsHidden: Bool)
    {
        mArrow.isHidden = arrowIsHidden
    }
    
    func setArrowOpen(arrowOpen: Bool)
    {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = (arrowOpen ? 45: 0) * (Double.pi / 180)
        rotationAnimation.fillMode = .forwards
        rotationAnimation.isRemovedOnCompletion = false
        mArrow.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func setLevel(level: Int)
    {
        mArrow.frame.origin.x = CGFloat(10 + (20 * level))
    }
    
    func setTitle(title: String)
    {
        mTitle.text = title
        mTitle.frame.size.width = Constant.mainFrame.size.width - (mArrow.frame.origin.x + mArrow.frame.width + 10) - 10
        mTitle.sizeToFit()
        mTitle.setPosition = CGPoint(x: mArrow.frame.origin.x + mArrow.frame.width + 10, y: 10)
        
        mSection.isHidden = true
        mTitle.isHidden = false
    }
    
    func setValue(value: Int)
    {
        mValue.text = String(value)
        mValue.frame.size.width = Constant.mainFrame.size.width - 20
        mValue.sizeToFit()
        mValue.setPosition = CGPoint(x: mTitle.frame.origin.x, y: mTitle.frame.origin.y + mTitle.frame.height + 5)
        mValue.isHidden = false
    }
    func setSection(section: String)
    {
        mSectionTitle.text = section
        mSectionTitle.frame.size.width = mSection.frame.width - 20
        mSectionTitle.sizeToFit()
        
        mSection.frame.size.height = mSectionTitle.frame.height + 26
        mSectionTitle.setPosition = CGPoint(x: 10, y: mSection.frame.height - mSectionTitle.frame.height - 6)
        
        mSection.isHidden = false
        mTitle.isHidden = true
        mValue.isHidden = true
    }
    
    func setlineHidden(lineHidden: Bool)
    {
        mLine.isHidden =  true
           
    }
}
