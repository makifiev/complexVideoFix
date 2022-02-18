//
//  GalleryView.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.08.2021.
//

import Foundation
import UIKit
import Alamofire

@objc protocol GalleryViewDelegate:AnyObject
{
    func galleryImageAtIndex(index:Int, success: @escaping (UIImage?) -> Void, failure: @escaping (String) -> Void)
    @objc optional func galleryCaptionsAtIndex(index: Int) -> NSArray
    @objc optional func galleryReloadData()
    @objc optional func galleryCurrentIndex(index: Int)
}

class GalleryView: UIView, UIScrollViewDelegate
{
    var mScroll: UIScrollView!
    var mCount: Int!
    var mImages: NSMutableDictionary!
    var mStartImage: Int!
    var mAutoScroll: Bool!
    var mAutoUpdate: Bool!
    
    var mTimer = Timer()
    var mUpdating: Bool = false
    weak var mDelegate: GalleryViewDelegate?
    
    var ReloadPosition = 6
    
    func removefromSuperview()
    {
        self.invalidateTimer()
        super.removeFromSuperview()
    }
    
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: 0, width: Constant.mainFrame.size.width, height: Constant.mainFrame.size.height / 2))
        self.backgroundColor = UIColor.Black
        mImages = NSMutableDictionary()
        self.addScroll()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addScroll()
    {
        mScroll = UIScrollView()
        mScroll.frame = self.frame
        mScroll.isPagingEnabled = true
        mScroll.isHidden = true
        mScroll.delegate = self
        self.addSubview(mScroll)
    }
    
    func showImages(count: Int)
    {
        mCount = count
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: mScroll.frame.height)
        
        if mScroll.isHidden
        {
            mScroll.contentOffset = CGPoint(x: mScroll.frame.width + CGFloat(mStartImage ?? 0), y: mScroll.contentOffset.y)
            mScroll.isHidden = false
        }
        
        if count != 0
        {
            let max = (count > 1 && mAutoUpdate) ? count : count
            
            for i in stride(from: 0, to: max, by: 1)
            {
                var frame = mScroll.viewWithTag(i + 10)
                if frame == nil
                {
                    frame = UIView()
                    frame!.frame = CGRect(x: mScroll.frame.width * CGFloat(i), y: 0, width: mScroll.frame.width, height: mScroll.frame.height)
                    frame!.tag = i + 10
                    mScroll.addSubview(frame!)
                    
                    let imageView = UIImageView()
                    imageView.tag = 100
                    imageView.alpha = 0
                    frame!.addSubview(imageView)
                    
                    let leftCaption = UILabel()
                    leftCaption.labelWithFrame(frame: CGRect.zero, colors: [UIColor.White, UIColor.clear])
                    leftCaption.frame.origin.y = frame!.frame.height
                    leftCaption.tag = 101
                    leftCaption.alpha = 0
                    frame!.addSubview(leftCaption)
                    
                    let rightCaption = UILabel()
                    rightCaption.labelWithFrame(frame: CGRect.zero, colors: [UIColor.White, UIColor.clear])
                    rightCaption.font = Constant.setMediumFont(size: 17)
                    rightCaption.tag = 102
                    rightCaption.alpha = 0
                    frame!.addSubview(rightCaption)
                    
                    let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
                    if #available(iOS 13.0, *) {
                        indicator.style = .medium
                    } else {
                        indicator.style = .white
                    }
                    indicator.color = .White
                    indicator.center = CGPoint(x: frame!.frame.width / 2, y: frame!.frame.height / 2)
                    indicator.tag = 103
                    frame!.addSubview(indicator)
                    indicator.sendSubviewToBack(indicator)
                }
                if mImages[frame?.tag] == nil
                {
                    self.updateFrame(frame: frame, i: i)
                }
            }
            if count > 1
            {
//                self.updateTimer()
            }
            else
            {
                mScroll.isUserInteractionEnabled = false
            }
        }
        else
        {
            let noData = UILabel()
            noData.labelWithFrame(frame: CGRect.zero, colors: [UIColor.white, UIColor.clear])
            noData.text = "Нет данных"
            noData.font = Constant.setMediumFont(size: 17)
            noData.alpha = 0
            noData.sizeToFit()
            noData.center = CGPoint(x: mScroll.frame.width / 2, y: mScroll.frame.height / 2)
            self.addSubview(noData)
            UIView.animate(withDuration: 0.3) {
                noData.alpha = 1
            }
        }
    }
    func updateFrame(frame: UIView!, i: Int)
    {
        
        let leftCaption:UILabel = frame.viewWithTag(101) as! UILabel
        let rightCaption: UILabel = frame.viewWithTag(102) as! UILabel
        
        if mDelegate?.galleryCaptionsAtIndex != nil
        {
            let captions = mDelegate?.galleryCaptionsAtIndex!(index: i)
            
            leftCaption.font = Constant.setMediumFont(size: 17)
            leftCaption.text = captions![0] as? String
            leftCaption.frame.size.width = self.frame.width - 20
            leftCaption.sizeToFit()
            
            if leftCaption.frame.size.height > 40
            {
                leftCaption.font = Constant.setMediumFont(size: 14)
                leftCaption.frame.size.width = self.frame.width - 20
                leftCaption.sizeToFit()
            }
            
            leftCaption.setPosition = CGPoint(x: 10, y: frame.frame.height - leftCaption.frame.height - 10)
            
            rightCaption.text = captions![1] as? String
            rightCaption.frame.size.width = self.frame.width - 20
            rightCaption.sizeToFit()
            rightCaption.setPosition = CGPoint(x: frame.frame.width - rightCaption.frame.width - 10, y: leftCaption.frame.origin.y)
        }
        
        var indicator = UIActivityIndicatorView()
        
        if frame.viewWithTag(103) is UIActivityIndicatorView
        {
            indicator = frame.viewWithTag(103) as! UIActivityIndicatorView
            indicator.startAnimating()
        }
        
        mDelegate?.galleryImageAtIndex(index: i, success:
                                        { (image) in
                                            if image != nil
                                            {
                                                self.mImages.setObject(image!, forKey: frame.tag as NSCopying)
                                                
                                                var width = (image!.size.width * leftCaption.frame.origin.y) / image!.size.height
                                                var height = leftCaption.frame.origin.y
                                                
                                                if width > self.mScroll.frame.width
                                                {
                                                    width = self.mScroll.frame.width
                                                    height = image!.size.height * width / image!.size.width
                                                }
                                                
                                                let imageView:UIImageView = frame.viewWithTag(100) as! UIImageView
                                                imageView.image = image
                                                imageView.frame.size = CGSize(width: width, height: height)
                                                imageView.backgroundColor = UIColor.Red
                                                imageView.center = CGPoint(x: indicator.center.x, y: leftCaption.frame.origin.y / 2)
                                                
                                                UIView.animate(withDuration: 0.3)
                                                {
                                                    imageView.alpha = 1
                                                    leftCaption.alpha = 1
                                                    rightCaption.alpha = 1
                                                }
                                                completion:
                                                {
                                                    (finished: Bool) in
                                                    indicator.stopAnimating()
                                                }
                                            }
                                        }, failure: { (reason) in
                                            indicator.stopAnimating()
                                            self.addError(reason: reason, frame: frame)
                                        })
    }
    func addError(reason: String, frame: UIView)
    {
        let error: UILabel = UILabel()
        error.labelWithFrame(frame: CGRect.zero, colors: [UIColor.White, UIColor.clear])
        error.frame.size.width = frame.frame.width - 50
        error.text = reason
        error.font = Constant.setFontBold(size: 17)
        error.alpha = 0
        error.textAlignment = NSTextAlignment.center
        error.sizeToFit()
        error.center = CGPoint(x: frame.frame.width / 2, y: frame.frame.height / 2)
        frame.addSubview(error)
        
        UIView.animate(withDuration: 0.3) {
            error.alpha = 1
        }
    }
    func loadImages(count: Int)
    {
        self.clearWithCompletion(completionFunc:
                                    {
                                        self.mImages.removeAllObjects()
                                        self.showImages(count: count)
                                    }, animated: false)
    }
    func clearWithCompletion(completionFunc: @escaping () -> Void, animated: Bool)
    {
        self.invalidateTimer()
        
        UIView.animate(withDuration: animated ? 0.2 : 0)
        {
            self.mScroll.alpha = 0
        }
        completion:
        { (finished: Bool) in
            self.mScroll.removeChildren()
            self.mScroll.contentOffset = CGPoint.zero
            self.mScroll.alpha = 1

            completionFunc()
        }
    }
    func scrollToPosition(position: Int, animated: Bool)
    {
        mScroll.setContentOffset(CGPoint(x: mScroll.frame.width * CGFloat(position), y: mScroll.contentOffset.y), animated: animated)
    }
    func updateTimer()
    {
        self.invalidateTimer()
        let currentImage: Int = Int(mScroll.contentOffset.x / mScroll.frame.width)
        if mAutoUpdate && currentImage > ReloadPosition && !mUpdating
        {
            mUpdating = true
            if mDelegate?.galleryReloadData != nil
            {
                mDelegate?.galleryReloadData?()
            }
        }
        
        if mDelegate?.galleryCurrentIndex != nil
        {
            mDelegate?.galleryCurrentIndex?(index: currentImage)
        }
        
        if currentImage != mCount
        {
            if mAutoScroll
            {
                mTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(showNextImage), userInfo: nil, repeats: false)
            }
        }
        else
        {
            if mAutoUpdate
            {
                mTimer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(rebuild), userInfo: nil, repeats: false)
            }
        }
    }
    func invalidateTimer()
    {
        mTimer.invalidate()
    }
    
    @objc func showNextImage()
    {
        mScroll.setContentOffset(CGPoint(x: mScroll.contentOffset.x + mScroll.frame.width, y: mScroll.contentOffset.y), animated: true)
    }
    
    @objc func rebuild()
    {
        if Connectivity.isConnectedToInternet() {
            
            for i in 0..<mCount * 2
            {
                let frame = mScroll.viewWithTag(i + 10)
                let contentWidth = mScroll.contentSize.width - frame!.frame.width
                if frame!.frame.origin.x >= contentWidth
                {
                    let image: UIImage? = mImages[frame!.tag] as? UIImage
                    mImages.removeObject(forKey: frame!.tag)
                    
                    frame!.frame.origin.x -= contentWidth
                    frame!.tag -= mCount
                    
                    if image != nil
                    {
                        mImages.setObject(image!, forKey: frame!.tag as NSCopying)
                    }
                }
                else
                {
                    frame!.removeFromSuperview()
                    mImages.removeObject(forKey: frame!.tag)
                }
            }
        }
        mScroll.contentOffset = CGPoint.zero
        self.showImages(count: mCount)
        mUpdating = false
    }
    
    func updateImages()
    {
        for item in mCount..<mCount*2
        {
            let frame = mScroll.viewWithTag(item + 10)
            self.updateFrame(frame: frame ?? UIView(), i: item - mCount)
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.updateTimer()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateTimer()
    }
}

