//
//  DummyController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 19.10.2021.
//

import Foundation
import UIKit
import GoogleMapsUtils
import CoreData

protocol DummyControllerDelegate: AnyObject {
    func dummyDidHide()
    func complexOffsetDidChange(offset: Float)
}

class DummyController : UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate
{
    var mDummy: Dummy!
    var mScroll: UIScrollView!
    var mBackGround: UIView!
    var mShowStreetView: UIBarButtonItem!
    var mInformation: UIScrollView!
    var mHeight = 0
    var mYoffset = 0
    var mHasCoordinate:Bool!
    var mShowingStreetView: Bool!
    weak var mDelegate: DummyControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        mShowingStreetView = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        if mHasCoordinate && !mShowingStreetView
        {
            mDelegate?.dummyDidHide()
        }
    }
    init(withDummy:Dummy)
    {
        super.init(nibName: nil, bundle: nil)
        mDummy = withDummy
        mHasCoordinate = (Int(mDummy.lat) != 0)
        if mHasCoordinate
        {
            mShowStreetView = UIBarButtonItem(image: UIImage(named: "streetview-toggle"), style: .done, target: self, action: #selector(showStreetView))
            self.navigationItem.setRightBarButton(mShowStreetView, animated: true)
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.navigationItem.title = "КВФ \(mDummy.name != nil ? mDummy.name ?? "" : "КВФ Черновик" )"
        
        self.view = UIView(frame: Constant.mainFrame)
        self.view.backgroundColor = .clear
        self.edgesForExtendedLayout = []
        
        mScroll = UIScrollView(frame: self.view.frame)
        mScroll.contentInset = UIEdgeInsets(top: mHasCoordinate ? CGFloat(Constant.complexPanelOffset) : 0, left: 0, bottom: CGFloat(Constant.iPhoneXTabBarCoefficient * 3), right: 0)
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: mScroll.frame.height + Constant.navigationBarHeight(navigationController: self.navigationController!))
        mScroll.backgroundColor = .clear
        mScroll.showsVerticalScrollIndicator = false
        mScroll.delaysContentTouches = false
        mScroll.delegate = self
        self.view.addSubview(mScroll)
        
        if Constant.iOS11IsAvailable()
        {
            mScroll.contentInsetAdjustmentBehavior = .never
        }
        if !mHasCoordinate
        {
            mBackGround = UIView(frame: Constant.mainFrame)
            mBackGround.setBlur()
            self.view.addSubview(mBackGround)
            self.view.sendSubviewToBack(mBackGround)
        }
        else
        {
            mScroll.setBlurWithoutStyle(size: CGSize(width: self.view.frame.width, height: mScroll.contentSize.height + mScroll.frame.height))
        }
        self.addInformation()
    }
    func addInformation()
    {
        mInformation = UIScrollView()
        mInformation.frame = CGRect(x: 0, y: 0, width: mScroll.frame.width, height: mScroll.frame.height)
        mInformation.backgroundColor = UIColor.clear
        mInformation.showsVerticalScrollIndicator = false
        mInformation.delaysContentTouches = false
        mInformation.isScrollEnabled = false
        mInformation.contentSize = CGSize(width: 0, height: 14)
        mScroll.addSubview(mInformation)
        self.addInformationViews()
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: mInformation.contentSize.height + Constant.topBarHeight)
    }
    func addInformationViews()
    {
        self.addMainInformation(info: [["Адрес", mDummy.placeName ?? "Нет данных"],
                                       ["Класс",  mDummy.clName ?? "Нет данных"],
                                       ["Тип", mDummy.typeName ?? "Нет данных"],
                                       ["Серийный номер", (mDummy.serialNumber) != "" ? mDummy.serialNumber : "Нет данных"],
                                       ["Инвентарный номер", (mDummy.inventoryNumber ?? "Нет данных")  != "" ? mDummy.inventoryNumber : "Нет данных"],
                                       ["Примечание", (mDummy.note ?? "Нет данных") != "" ? mDummy.note : "Нет данных"]], view: mInformation)
    }
    func addMainInformation(info: NSArray, view: UIScrollView)
    {
        let backGround = UIView(frame: CGRect(x: 0, y: view.contentSize.height, width: view.frame.width, height: 40))
        backGround.backgroundColor = .GrayApha
        view.addSubview(backGround)
        
        let mainInformation = UILabel()
        mainInformation.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        mainInformation.font = Constant.setMediumFont(size: 12)
        mainInformation.text = "ОСНОВНЫЕ СВЕДЕНИЯ"
        mainInformation.sizeToFit()
        mainInformation.setPosition = CGPoint(x: 10, y: backGround.frame.height - mainInformation.frame.height - 6)
        backGround.addSubview(mainInformation)
        var y = backGround.frame.origin.y + backGround.frame.height
        for i in 0..<info.count
        {
            let array = info[i] as! NSArray
            let title = UILabel()
            title.labelWithFrame(frame: CGRect(x: 10, y: y + 20, width: 0, height: 0), colors: [UIColor.Blue, UIColor.clear])
            title.text = array[0] as? String
            title.font = Constant.setMediumFont(size: 17)
            title.sizeToFit()
            view.addSubview(title)
            
            let value = UILabel()
            value.labelWithFrame(frame: CGRect(x: title.frame.origin.x, y: title.frame.origin.y + title.frame.height, width: view.frame.width - title.frame.origin.x + 10, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
            value.attributedText = (array[1] as? String)?.attributedStringWithLineSpacing(lineSpacing: 2)
            value.font = Constant.setMediumFont(size: 14)
            value.sizeToFit()
            view.addSubview(value)
            y = value.frame.origin.y + value.frame.height
        }
        y += 20
        if Constant.iPhoneX
        {
            y += 55
        }
        view.contentSize = CGSize(width: view.frame.width, height: y)
        if view.frame.height > view.contentSize.height
        {
            view.frame.size.height = view.contentSize.height
        }
    }
    @objc func showStreetView()
    {
        mShowingStreetView = true
        let streetViewController = StreetViewController.init(withDummy: mDummy)
        self.navigationController!.pushViewController(streetViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mScroll
        {
            let view = mInformation
            if view != nil
            {
                let height = view!.frame.height
                if ((scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height || mYoffset > 0)
                        && (scrollView.contentOffset.y + scrollView.frame.height < scrollView.contentSize.height || mYoffset < mHeight - Int(height)))
                {
                    let y = scrollView.contentSize.height - scrollView.frame.height
                    view!.contentOffset = CGPoint(x: view!.contentOffset.x, y: view!.contentOffset.y + scrollView.contentOffset.y - y)
                    mYoffset = Int(view!.contentOffset.y)
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: y)
                }
                else if mYoffset <= 0
                {
                    view!.contentOffset = CGPoint(x: view!.contentOffset.x, y: CGFloat(mHeight) - height)
                }
                else if mYoffset >= mHeight - Int(height)
                {
                    view!.contentOffset = CGPoint(x: view!.contentOffset.x, y: CGFloat(mHeight) - height)
                }
                let offset = -(scrollView.contentInset.top + scrollView.contentOffset.y)
                if mHasCoordinate && offset > 0
                {
                    mDelegate?.complexOffsetDidChange(offset: Float(offset))
                }
                if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height
                {
                    scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.height
                }
            }
        }
    }
    override var shouldAutorotate: Bool
    {
        return false
    }
}

