//
//  SearchViewController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 20.07.2021.
//

import Foundation
import UIKit
import CoreData



@objc protocol SearchControllerDelegate: class
{
    func filtersChanged(filters:NSArray?)
    func selectComplex(complex: Complex)
    func changeMapType()
    func showUserLocation()
    func zoomInMap()
    func zoomOutMap()
}

class SearchViewController: UIViewController, UISearchBarDelegate, TableViewDelegate
{
    var mPanel = UIView()
    @IBOutlet var mainView: UIView!
    var mSearchBar = UISearchBar()
    var mSearchTag = UILabel()
    var mLogOut = UIButton()
    var mChangeMapType = UIButton()
    var mShowPanel = UIButton()
    var mZoomOutMap = UIButton()
    var mZoomInMap = UIButton()
    var mShowUserLocation = UIButton()
    
    var mFilters = UIView()
    var mScroll = UIScrollView()
    
    var operability = UILabel()
    
    var firstLine = UIView()
    var secondLine = UIView()
    var thirdLine = UIView()
    
    var cameraTypes = UILabel()
    var mtype = UIView()
    
    var mTransitLoadingIndicator = UIActivityIndicatorView()
    var mTransitLoadingError = UILabel()
    var scrollHeight: CGFloat!
    
    var mSearchResult: TableView!
    var mComplexNames: NSArray!
    var heightY: CGFloat = 0.0
    var mCurrentComplexName: String = ""
    var mCurrentSearchString = ""
    var mTypeWorkStates = UIView()
    var mPressedTypeFilterPosition:CGPoint!
    var mTransits: NSMutableArray!
    var mShowingTransitPhoto: Bool!
    var CopyAlertlabel = UILabel()
    var checkCreated = false
    
    weak var mDelegate: SearchControllerDelegate?
    
    var mSearchResultComplexes: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        
        self.edgesForExtendedLayout = []
        
        self.mainView.isUserInteractionEnabled = true
        setPanel()
        setFilters()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(databaseUpdated), name: NSNotification.Name(rawValue: Constant.dataBaseUpdated), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.dataBaseUpdated), object: nil)
    }
    
    @objc func databaseUpdated()
    {
        if checkCreated == false
        {
        self.addTypeFilters()
        }
    }
    @objc func changeMapType()
    {
        mDelegate?.changeMapType()
    }
    
    func setPanel()
    {
        mPanel = UIView()
        print(self.view.frame.width)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            mPanel.frame = CGRect(x: 8, y: 30, width: 428, height: 66)
            mPanel.layer.cornerRadius = 15
        }
        else
        {
            mPanel.frame = CGRect(x: -1, y: 0, width: Int(self.view.frame.width) + 2, height: 66 + Constant.iPhoneNavBarCoefficient)
            mPanel.y = Constant.statusBarHeight - mPanel.frame.height + 1
        }
        
        
        mPanel.layer.borderWidth = 0.3
        mPanel.layer.borderColor = UIColor.DarkGray.cgColor
        mPanel.setBlur()
        mPanel.layoutIfNeeded()
        
        self.view.addSubview(mPanel)
        
        mSearchBar = UISearchBar()
        mSearchBar = UISearchBar().setSearchBarWithFrame(searchBar: mSearchBar, frame: CGRect(x: 10, y: (Constant.iPhoneX ? 25 : 28) + Constant.iPhoneNavBarCoefficient, width: Int(mPanel.frame.size.width) - 20, height: 34),
                                                         textColor: UIColor.darkGray,
                                                         placeHolder: "Найти КВФ по номеру или адресу")
        mSearchBar.alpha = 0
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            mSearchBar.alpha = 1
            mSearchBar.frame = CGRect(x: 10, y: 16, width: Int(mPanel.frame.size.width) - 20, height: 34)
        }
 
       
        mSearchBar.delegate = self
        mSearchBar.layoutIfNeeded()
        mPanel.addSubview(mSearchBar)
        
        mSearchTag = UILabel()
        mSearchTag.labelWithFrame(frame: .zero, colors: [UIColor.white, UIColor.DarkGray])
        mSearchTag.frame.origin.x = mSearchBar.frame.origin.x + 14
        
        mPanel.layoutIfNeeded()
        mSearchTag.font = Constant.setFontBold(size: 15)
        mSearchTag.clipsToBounds = true
        mSearchTag.layer.cornerRadius = 3
        mSearchTag.adjustsFontSizeToFitWidth = false
        mSearchTag.lineBreakMode = .byTruncatingTail
        mPanel.addSubview(mSearchTag)
        mSearchTag.isHidden = true
        
        mLogOut = UIButton()
        mLogOut.setButtonWithImage(image: "logout", highlightedImage: "logout-selected")
        mLogOut.frame = CGRect(x: 8, y: mPanel.frame.origin.y + mPanel.frame.height + 8, width: 35, height: 35)
        mLogOut.isHidden = true
        mLogOut.layer.cornerRadius = mLogOut.frame.height / 2
        mLogOut.layer.borderWidth = 0.3
        mLogOut.titleLabel?.text = ""
        mLogOut.layer.borderColor = UIColor.DarkGrayAlpha.cgColor
        mLogOut.addTarget(self, action: #selector(showLogOutAlert), for: .touchUpInside)
        mLogOut.setBlur()
        self.view.addSubview(mLogOut)
        self.view.sendSubviewToBack(mLogOut)
        
        mChangeMapType = UIButton()
        mChangeMapType.setButtonWithImage(image: "map-toggle-map", highlightedImage: "map-toggle-map-selected")
        mChangeMapType.frame = CGRect(x: mLogOut.frame.origin.x + mLogOut.frame.width + 8, y: mLogOut.frame.origin.y, width: 35, height: 35)
        mChangeMapType.layer.cornerRadius = mChangeMapType.frame.height / 2
        mChangeMapType.layer.borderColor = UIColor.DarkGrayAlpha.cgColor
        mChangeMapType.layer.borderWidth = 0.3
        mChangeMapType.addTarget(self, action: #selector(changeMapType), for: .touchUpInside)
        mChangeMapType.setBlur()
        self.view.addSubview(mChangeMapType)
        self.view.sendSubviewToBack(mChangeMapType)
        
        mShowPanel = UIButton()
        mShowPanel.setButtonWithImage(image: "magnifying-glass", highlightedImage: "magnifying-glass-selected")
        mShowPanel.frame = mChangeMapType.frame
       
        mShowPanel.isHidden = true
        mShowPanel.layer.cornerRadius = mChangeMapType.layer.cornerRadius
        mShowPanel.layer.borderWidth = mChangeMapType.layer.borderWidth
        mShowPanel.layer.borderColor = mChangeMapType.layer.borderColor
        mShowPanel.addTarget(self, action: #selector(showPanel), for: .touchUpInside)
        mShowPanel.setBlur()
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            mLogOut.frame = CGRect(x: self.view.frame.width - (mShowPanel.frame.width * 2) - 16, y: mPanel.frame.origin.y, width: 35, height: 35)
            mChangeMapType.frame = CGRect(x: mLogOut.frame.origin.x + mLogOut.frame.width + 8, y: mLogOut.frame.origin.y, width: 35, height: 35)
            mShowPanel.frame = CGRect(x: mChangeMapType.frame.origin.x , y: mLogOut.frame.origin.y, width: 35, height: 35)
            mShowPanel.isHidden = true
        }
        else
        {
            mShowPanel.frame.origin.x = self.view.frame.width - mShowPanel.frame.width - 8
        }
        
        self.view.addSubview(mShowPanel)
        self.view.sendSubviewToBack(mShowPanel)
        
        
        
        mZoomOutMap = UIButton()
        mZoomOutMap.setButtonWithImage(image: "map-zoom-out", highlightedImage: "map-zoom-out-selected")
        mZoomOutMap.frame = mShowPanel.frame
        mZoomOutMap.frame.origin.y = self.view.frame.height - mZoomOutMap.frame.height - Constant.tabBarHeight! - 8
        mZoomOutMap.layer.cornerRadius = mChangeMapType.layer.cornerRadius
        mZoomOutMap.layer.borderWidth = mChangeMapType.layer.borderWidth
        mZoomOutMap.layer.borderColor = mChangeMapType.layer.borderColor
        mZoomOutMap.addTarget(mDelegate, action: #selector(SearchControllerDelegate.zoomOutMap), for: .touchUpInside)
        mZoomOutMap.setBlur()
        self.view.addSubview(mZoomOutMap)
        self.view.sendSubviewToBack(mZoomOutMap)
        
        mZoomInMap = UIButton()
        mZoomInMap.setButtonWithImage(image: "map-zoom-in", highlightedImage: "map-zoom-in-selected")
        mZoomInMap.frame = mZoomOutMap.frame
        mZoomInMap.frame.origin.y = mZoomOutMap.frame.origin.y - mZoomInMap.frame.height - 8
        mZoomInMap.layer.cornerRadius = mChangeMapType.layer.cornerRadius
        mZoomInMap.layer.borderWidth = mChangeMapType.layer.borderWidth
        mZoomInMap.layer.borderColor = mChangeMapType.layer.borderColor
        mZoomInMap.addTarget(mDelegate, action: #selector(SearchControllerDelegate.zoomInMap), for: .touchUpInside)
        mZoomInMap.setBlur()
        self.view.addSubview(mZoomInMap)
        self.view.sendSubviewToBack(mZoomInMap)
        
        mShowUserLocation = UIButton()
        mShowUserLocation.setButtonWithImage(image: "map-location", highlightedImage: "map-location-selected")
        mShowUserLocation.frame = mZoomInMap.frame
        mShowUserLocation.frame.origin.y = mZoomInMap.frame.origin.y - mShowUserLocation.frame.height - 8
        mShowUserLocation.layer.cornerRadius = mChangeMapType.layer.cornerRadius
        mShowUserLocation.layer.borderWidth = mChangeMapType.layer.borderWidth
        mShowUserLocation.layer.borderColor = mChangeMapType.layer.borderColor
        mShowUserLocation.addTarget(mDelegate, action: #selector(SearchControllerDelegate.showUserLocation), for: .touchUpInside)
        mShowUserLocation.setBlur()
        self.view.addSubview(mShowUserLocation)
        self.view.sendSubviewToBack(mShowUserLocation)
        
        
        CopyAlertlabel.frame = CGRect(x: 8, y: -30 , width: self.view.frame.width - 16, height: 35)
        
        CopyAlertlabel.text = ""
        CopyAlertlabel.textAlignment = .center
        CopyAlertlabel.textColor = UIColor.black
        CopyAlertlabel.alpha = 0
        CopyAlertlabel.backgroundColor = .white
        CopyAlertlabel.layer.cornerRadius = CopyAlertlabel.frame.height / 2
        CopyAlertlabel.layer.borderColor = UIColor.DarkGrayAlpha.cgColor
        CopyAlertlabel.layer.borderWidth = 0.3
        CopyAlertlabel.layer.masksToBounds = true
        self.view.addSubview(CopyAlertlabel)
        self.view.bringSubviewToFront(CopyAlertlabel)
        
        let array = [mPanel, mLogOut, mChangeMapType, mShowPanel, mZoomOutMap, mZoomInMap, mShowUserLocation]
        for item in array
        {
            checkStatusBarExtendedY(view: item)
        }
    }
    
    func showCopyAlertlabel(text: String)
    {
        CopyAlertlabel.text = "Скопировано: \(text)"
        UIView.animate(withDuration: 0.3) {
            self.CopyAlertlabel.center.y = self.mLogOut.center.y
            self.CopyAlertlabel.alpha = 1
        } completion: { (finished: Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
            {
                UIView.animate(withDuration: 0.3) {
                    self.CopyAlertlabel.center.y = -30
                    self.CopyAlertlabel.alpha = 0
                }
                
            }
        }
    }
    
    func hidePanel()
    {
        if mSearchTag.isHidden && mShowPanel.isHidden && mFilters.isHidden
        {
            mLogOut.isHidden = false
            mChangeMapType.isHidden = false
            mShowPanel.isHidden = false
            UIView.animate(withDuration: 0.3, animations:
                            {
                                if UIDevice.current.userInterfaceIdiom == .pad
                                {
                                    
                                }
                                else
                                {
                                self.mPanel.frame.origin.y = Constant.statusBarHeight - self.mPanel.frame.height + 1
                                self.mSearchBar.alpha = 0
                                }
                            })
        }
    }
    
    @objc func showPanel()
    {
        UIView.animate(withDuration: 0.3) {
            if UIDevice.current.userInterfaceIdiom == .pad
            {
            self.mPanel.frame.origin.y = 30
            }
            else
            {
            self.mPanel.frame.origin.y = -1.5
            }
            self.mSearchBar.alpha = 1
        } completion: { _ in
            self.mLogOut.isHidden = true
            self.mChangeMapType.isHidden = true
            self.mShowPanel.isHidden = true
            
            self.mSearchBar.becomeFirstResponder()
        }
        
        
    }
    
    func setFilters()
    {
        mFilters = UIView()
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            mFilters.frame = CGRect(x: 8,
                                    y: mPanel.frame.height + mPanel.frame.origin.y + 0.5,
                                    width: mPanel.frame.width,
                                    height: self.view.frame.height - (mPanel.frame.height + mPanel.frame.origin.y) - Constant.tabBarHeight! + 1 - 30)
            
            mFilters.layer.borderWidth = 0.3
            mFilters.layer.borderColor = UIColor.DarkGray.cgColor
            mFilters.layer.cornerRadius = 15
            
        }
        else
        {
            mFilters.frame = CGRect(x: 0, y: -1.5 + mPanel.frame.height, width: self.view.frame.width, height: self.view.frame.height - (-1.5 + mPanel.frame.height) - Constant.tabBarHeight! + 1)
        }
        
        mFilters.alpha = 0
        mFilters.isHidden = true
        mFilters.setBlur()
        self.view.addSubview(mFilters)
        checkStatusBarExtendedY(view: mFilters)
        mScroll = UIScrollView()
        mScroll.frame.size = mFilters.frame.size
        mScroll.backgroundColor = .clear
        mScroll.showsVerticalScrollIndicator = false
        mScroll.delaysContentTouches = false
        mFilters.addSubview(mScroll)
        
        scrollHeight = mScroll.frame.size.height
        
        addOperabilityFilters()
        addTypeFilters()
        setSearchResultTable()
    }
    
    func addOperabilityFilters()
    {
        operability = UILabel()
        operability.labelWithFrame(frame: CGRect(x: 10, y: 10, width: 0, height: 0), colors:  [UIColor.DarkGray, UIColor.clear])
        operability.text = "РАБОТОСПОСОБНОСТЬ КАМЕР"
        operability.font = Constant.setMediumFont(size: 12)
        operability.sizeToFit()
        mScroll.addSubview(operability)
        
        firstLine = UIView(frame: CGRect(x: 0, y: operability.frame.origin.y + operability.frame.height + 10, width: mFilters.frame.width, height: 0.5))
        
        
        firstLine.backgroundColor = UIColor.DarkGrayAlpha
        mScroll.addSubview(firstLine)
        firstLine.layoutIfNeeded()
        
        let states = [1, 0, 3, 2]
        let workStates = UIView()
        workStates.frame.origin.y = firstLine.frame.origin.y + firstLine.frame.height + 10
        mScroll.addSubview(workStates)
        
        var height = 0
        
        for item in states
        {
            let state = states[item]
            let button = UIButton()
            button.setButtonWithImage(image: "camera-white", highlightedImage: "camera-white")
            button.frame.size = CGSize(width: 60, height: 60)
            let firstEl = (Int(mFilters.frame.width) / states.count) * item
            let secEl = ((mFilters.frame.width / CGFloat(states.count)) - button.frame.width) / 2
            button.setPosition = CGPoint(x: firstEl + Int(secEl), y: 0)
            button.tag = state
            button.setBackgroundColor(Constant.colors[state]!, for: .normal)
            button.setBackgroundColor(Constant.colorsAlpha[state]!, for: .highlighted)
            button.addTarget(self, action: #selector(filtersChanged), for: .touchUpInside)
            button.layer.cornerRadius = button.frame.size.height / 2
            button.layer.masksToBounds = true
            workStates.addSubview(button)
            
            let label = UILabel()
            label.labelWithFrame(frame: CGRect(x: 0, y: button.frame.height + 5, width: button.frame.width + 20, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
            
            label.text = Constant.workTitles[state]
            label.font = Constant.setMediumFont(size: 10)
            label.textAlignment = .center
            label.sizeToFit()
            label.center.x = button.center.x
            workStates.addSubview(label)
            
            height = max(height, Int(label.frame.origin.y + label.frame.height))
        }
        workStates.frame.size = CGSize(width: mFilters.frame.width, height: CGFloat(height))
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: workStates.frame.origin.y + workStates.frame.height)
    }
    
    
    
    func addTypeFilters()
    {
        checkCreated = true
        secondLine = UIView(frame: CGRect(x: 0, y: mScroll.contentSize.height + 10, width: mFilters.frame.width, height: 0.5))
        secondLine.backgroundColor = UIColor.DarkGrayAlpha
        secondLine.layoutIfNeeded()
        mScroll.addSubview(secondLine)
        
        cameraTypes = UILabel()
        cameraTypes.labelWithFrame(frame: CGRect(x: 10, y: secondLine.frame.origin.y + secondLine.frame.height + 10, width: 0, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
        cameraTypes.text = "ТИПЫ КАМЕР"
        cameraTypes.font = Constant.setMediumFont(size: 12)
        cameraTypes.sizeToFit()
        mScroll.addSubview(cameraTypes)
        
        thirdLine = UIView(frame: CGRect(x: 0, y: cameraTypes.frame.origin.y + cameraTypes.frame.height + 10, width: mFilters.frame.width, height: 0.5))
        
        thirdLine.backgroundColor = UIColor.DarkGrayAlpha
        thirdLine.layoutIfNeeded()
        mtype = UIView()
        mtype.frame.origin.y = thirdLine.frame.origin.y + thirdLine.frame.height + 10
        mScroll.addSubview(mtype)
        
        mtype.removeChildren()
        mComplexNames = CoreDataStack.sharedInstance.getComplexClassNames()
        
        let rowCount:Int = Constant.iPhone6Plus ? 5 : 4
        var height = 0
        for i:Int in stride(from: 0, to: mComplexNames.count, by: 1)
        {
            
            
            let name = mComplexNames[i] as! String
            let firstChar = name[name.startIndex].uppercased()
            let lastChar = name[name.index(before: name.endIndex)].lowercased()
            let shortName = "\(firstChar)\(lastChar)"
            
            let typeButton: UIButton = UIButton()
            typeButton.setButtonWithTitle(title: shortName, font: Constant.setFontBold(size: 18), colors: [UIColor.White, UIColor.White, UIColor.clear])
            typeButton.frame.size = CGSize(width: 60, height: 60)
            let firstElement = (mFilters.frame.size.width / CGFloat(rowCount))
            let secondElement = (i - rowCount * Int(round(Double(i / rowCount))))
            let thirdelement = ((mFilters.frame.size.width / CGFloat(rowCount)) - typeButton.frame.size.width) / 2
            let x = firstElement * CGFloat(secondElement) + thirdelement
            let y = (35 + typeButton.frame.size.height) * CGFloat(round(Double(i / rowCount)))
            typeButton.frame.origin = CGPoint(x: x, y: y)
            typeButton.layer.cornerRadius = typeButton.frame.width / 2
            typeButton.layer.masksToBounds = true
            typeButton.tag = i
            typeButton.addTarget(self,action:#selector(typeFilterPressed),
                                 for:.touchUpInside)
            typeButton.setBackgroundColor(UIColor.MediumGray, for: .normal)
            typeButton.setBackgroundColor(UIColor.MediumGrayApha, for: .highlighted)
            mtype.addSubview(typeButton)
            
            let typeLabel : UILabel = UILabel()
            typeLabel.labelWithFrame(frame: CGRect(x: 0, y: typeButton.frame.origin.y + typeButton.frame.size.height + 5, width: typeButton.frame.size.width + 20, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
            typeLabel.text = mComplexNames[i]  as! String
            typeLabel.font = Constant.setMediumFont(size: 10)
            typeLabel.textAlignment = .center
            typeLabel.sizeToFit()
            typeLabel.center.x = typeButton.center.x
            mtype.addSubview(typeLabel)
            height = Int(max(CGFloat(height), typeLabel.frame.origin.y + typeLabel.frame.height))
        }
        
        mtype.frame.size = CGSize(width: mFilters.frame.width, height: CGFloat(height))
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: mtype.frame.origin.y + mtype.frame.height + 10)
    }
    
    @objc func typeFilterPressed(sender:UIButton)
    {
        let states = [-1, 1, 0, 3, 2, -2]
        mCurrentComplexName = mComplexNames[Int(sender.tag)] as! String
        let name = mCurrentComplexName
        let firstChar = name[name.startIndex].uppercased()
        let lastChar = name[name.index(before: name.endIndex)].lowercased()
        let shortName = "\(firstChar)\(lastChar)"
        mTypeWorkStates = UIView()
        mFilters.addSubview(mTypeWorkStates)
        let operability: UILabel = UILabel()
        operability.labelWithFrame(frame: CGRect(x: 10, y: 10, width: 0, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
        operability.text = "РАБОТОСПОСОБНОСТЬ КАМЕР \(mCurrentComplexName.uppercased())"
        operability.font = Constant.setMediumFont(size: 12)
        operability.alpha = 0
        operability.tag = 100
        operability.sizeToFit()
        mTypeWorkStates.addSubview(operability)
        
        let line:UIView = UIView(frame: CGRect(x: 0, y: operability.y + operability.frame.size.height + 10, width: mFilters.frame.size.width, height: 0.5))
        line.backgroundColor = UIColor.DarkGrayAlpha
        line.alpha = 0
        line.tag = 101
        mTypeWorkStates.addSubview(line)
        
        mPressedTypeFilterPosition = mTypeWorkStates.convert(sender.frame.origin, from: sender.superview)
        var height = 0
        for item in stride(from: 0, to: states.count, by: 1)
        {
            var state = states[item]
            var workState: UIButton!
            if state == -2
            {
                workState = UIButton()
                workState.setButtonWithImage(image: "close-icon", highlightedImage: "close-icon-transparent")
                workState.layer.borderWidth = 1
                workState.layer.borderColor = UIColor.MediumGray2.cgColor
            }
            else
            {
                workState = UIButton()
                workState.setButtonWithTitle(title: shortName, font: Constant.setFontBold(size: 18), colors: [UIColor.White,UIColor.White, UIColor.clear])
            }
            workState.frame.size = sender.frame.size
            workState.frame.origin = mPressedTypeFilterPosition
            workState.layer.cornerRadius = workState.frame.width / 2
            workState.layer.masksToBounds = true
            workState.tag = state
            workState.alpha = 0
            workState.setBackgroundColor(Constant.colors[state]!, for: .normal)
            workState.setBackgroundColor(Constant.colorsAlpha[state]!, for: .highlighted)
            workState.addTarget(self,action:(state == -2 ? #selector(backToOperabilityFilters) : #selector(filtersChanged)),
                                for:.touchUpInside)
            mTypeWorkStates.addSubview(workState)
            
            let workStateLabel = UILabel()
            workStateLabel.labelWithFrame(frame: CGRect(x: 0,
                                                        y: workState.frame.height + 5,
                                                        width: workState.frame.width + 5,
                                                        height: 0), colors: [UIColor.darkGray, UIColor.clear])
            workStateLabel.text = Constant.workTitles[state]
            workStateLabel.font = Constant.setMediumFont(size: 10)
            workStateLabel.textAlignment = .center
            workStateLabel.alpha = 0
            workStateLabel.sizeToFit()
            mTypeWorkStates.addSubview(workStateLabel)
            
            let stateOne = ((mFilters.frame.width / (CGFloat(states.count) - 2)) - workState.frame.width) / 2
            
            let stateTwoFirst = (mFilters.frame.width / (CGFloat(states.count) - 2)) * 3
            let stateTwoSecond = (mFilters.frame.width / (CGFloat(states.count) - 2) - workState.frame.width) / 2
            
            let stateThreeFist = mFilters.frame.width / (CGFloat(states.count) - 2) * (CGFloat(item) - 1)
            let stateThreeSecond = (mFilters.frame.width / (CGFloat(states.count) - 2) - workState.frame.width) / 2
            
            UIView.animate(withDuration: 0.3) {
                let y = line.frame.origin.y + line.frame.height + 10
                if state == -1
                {
                    workState.setPosition = CGPoint(x: stateOne, y: y)
                }
                else if state == -2
                {
                    workState.setPosition = CGPoint(x: stateTwoFirst + stateTwoSecond, y: y)
                }
                else
                {
                    workState.setPosition = CGPoint(x: stateThreeFist + stateThreeSecond, y: y + 95)
                }
                workStateLabel.setPosition = CGPoint(x: 0, y: workState.y + workState.frame.height + 5)
                workStateLabel.center.x = workState.center.x
                workState.alpha = 1
            } completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.2) {
                    workStateLabel.alpha = 1
                }
            }
            height = max(height, Int(workStateLabel.frame.origin.y + workStateLabel.frame.height))
        }
        mTypeWorkStates.frame.size = CGSize(width: CGFloat(mFilters.frame.width), height: CGFloat(height))
        UIView.animate(withDuration: 0.3) {
            operability.alpha = 1
            line.alpha = 1
            self.mScroll.alpha = 0
        } completion: { (finished: Bool) in
            self.mScroll.isHidden = true
        }
        
    }
    
    @objc func backToOperabilityFilters()
    {
        mScroll.isHidden = false
        mCurrentComplexName = ""
        
        for view:UIView in mTypeWorkStates.subviews
        {
            UIView.animate(withDuration: 0.3, animations: {
                if view.tag < 100
                {
                    view.frame.origin = self.mPressedTypeFilterPosition
                }
                view.alpha = 0
                self.mScroll.alpha = 1
            }, completion: { (finished: Bool) in
                self.mTypeWorkStates.removeFromSuperview()
            })
        }
    }
    
    @objc func filtersChanged(sender: UIButton)
    {
        let workState = sender.tag
        let filters = [workState, mCurrentComplexName] as NSArray
        mDelegate?.filtersChanged(filters: filters)
        
        self.setSearchTag(tag: "\(mCurrentComplexName) \(Constant.workTitles[workState] ?? "")")
        self.hideFilters(shouldShowScrollView:false)
    }
    
    func hideFilters(shouldShowScrollView:Bool)
    {
        self.view.endEditing(true)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.mFilters.alpha = 0
            self.mSearchBar.frame.size.width = self.mPanel.frame.width - 20
        }, completion: {
            (value: Bool) in
            self.mFilters.isHidden = true
            if shouldShowScrollView
            {
                if self.mTypeWorkStates != nil
                {
                    self.mTypeWorkStates.removeFromSuperview()
                }
                
                self.mScroll.isHidden = false
                self.mScroll.alpha = 1
                
                self.mSearchResult.isHidden = true
                self.mSearchResult.alpha = 0
            }
        })
        mSearchBar.setShowsCancelButton(false, animated: true)
    }
    func setSearchTag(tag: String)
    {
        tag.stringWithoutDoubleSpaces()
        mSearchTag.text = " \(tag) "
        mSearchTag.frame.size = mSearchTag.sizeThatFits(CGSize(width: 0, height: mSearchTag.frame.size.height))
        if mSearchTag.frame.width > mSearchBar.frame.width - 55
        {
            mSearchTag.frame.size.width = mSearchBar.frame.width - 55
            
            //            mSearchTag.frame.size.width = mSearchBar.frame.width - 55
        }
        mSearchTag.frame.size.height = 20
        mSearchTag.center.y = mSearchBar.center.y - 1
        mSearchTag.isHidden = false
        
        mCurrentSearchString = mSearchBar.text ?? ""
        mSearchBar.text = " "
    }
    
    func checkStatusBarExtendedY(view: UIView)
    {
        let view = view
        if !Constant.iPhoneX && Constant.statusBarHeightCurrent ?? 0.0 > 20
        {
            view.y -= Constant.statusBarHeightCurrent ?? 0.0 / 2
        }
    }
    
    func setSearchResultTable()
    {
        
        mSearchResult = TableView.init(withStyle: .grouped)
        mSearchResult.frame = mScroll.frame
        mSearchResult.mTableViewDelegate = self
        mSearchResult.isHidden = true
        mSearchResult.alpha = 0
        mSearchResult.setCell(cell: SearchCell.self)
        mFilters.addSubview(mSearchResult)
        mTransitLoadingIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            mTransitLoadingIndicator.style = .medium
        } else {
            // Fallback on earlier versions
            mTransitLoadingIndicator.style = .white
        }
        mTransitLoadingIndicator.center.x = mFilters.frame.width / 2
        mTransitLoadingIndicator.frame.origin.y = 60
        mTransitLoadingIndicator.color = UIColor.DarkGray
        mSearchResult.addSubview(mTransitLoadingIndicator)
        
        mTransitLoadingError = UILabel()
        
        mTransitLoadingError.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        mTransitLoadingError.frame.size = CGSize(width: mFilters.frame.width - 10, height: 15)
        mTransitLoadingError.center = mTransitLoadingIndicator.center
        mTransitLoadingError.textAlignment = .center
        mTransitLoadingError.font = Constant.setMediumFont(size: 14)
        mTransitLoadingError.alpha = 0
        mSearchResult.addSubview(mTransitLoadingError)
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath: IndexPath) {
        let cell = cell as! SearchCell
        let data:NSArray = self.getDataForCellAtIndexPath(indexPath: atIndexPath)
        cell.selected(false, animated: false)
        cell.workState = data[0] as? Int ?? 0
        cell.name = data[1] as? String ?? ""
        cell.address = data[2] as? String ?? ""
        cell.lineHidden = atIndexPath.row == 0
    }
    
    func selectedCell(cell: UITableViewCell, atIndexPath: IndexPath) {
        let cell = cell as! SearchCell
        cell.selected(true, animated: true)
        
        if mTransits == nil
        {
            let complex: Complex = mSearchResultComplexes.object(at: atIndexPath) as! Complex
            self.setSearchTag(tag: "КВФ \(complex.name ?? "")")
            self.clearFilters()
            self.hideFilters(shouldShowScrollView: false)
            mDelegate?.selectComplex(complex: complex)
        }
    }
    
    func heightForRowAtIndexPath(indexPath: IndexPath) -> CGFloat {
        let data = self.getDataForCellAtIndexPath(indexPath: indexPath)
        
        let width = mSearchResult.frame.width - 50
        let fontRect = Constant.setMediumFont(size: 17)
        let fontAddress = Constant.setMediumFont(size: 14)
        let attributesRect: [NSAttributedString.Key: Any] = [.font: fontRect]
        let attributesAddress: [NSAttributedString.Key: Any] = [.font: fontAddress]
        let nameRect =  (data[1] as! NSString).boundingRect(with: CGSize(width: width, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributesRect, context: nil)
        let addressRect = (data[2] as! NSString).boundingRect(with: CGSize(width: width, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributesAddress, context: nil)
        return nameRect.size.height + addressRect.size.height + 25
    }
    
    func viewForHeaderInSection(section: Int) -> UIView
    {
        var result = ""
        if mTransits != nil
        {
            var count = mTransits.count
            count = count > 0 ? count - 1 : 0
            var transits = "ПРОЕЗДОВ"
            if (count < 11 || count > 20) && (count % 10 == 1)
            {
                transits = "ПРОЕЗД"
            }
            else if (count < 11 || count > 20) && (count % 10 > 0) && (count % 10 < 5)
            {
                transits = "ПРОЕЗДА"
            }
            result = "\(count) \(transits)"
        }
        else
        {
            result = "\(mSearchResultComplexes.fetchedObjects?.count ?? 0) КВФ"
        }
        let header = UIView()
        header.frame.size.width = self.view.frame.width
        let searchResult = UILabel()
        searchResult.labelWithFrame(frame: CGRect(x: 10, y: 10, width: 0, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
        searchResult.text = "РЕЗУЛЬТАТЫ ПОИСКА"
        searchResult.font = Constant.setMediumFont(size: 12)
        searchResult.sizeToFit()
        header.addSubview(searchResult)
        
        let resultNumber = UILabel()
        resultNumber.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        resultNumber.text = result
        resultNumber.font = Constant.setFontBold(size: 12)
        resultNumber.sizeToFit()
        resultNumber.setPosition = CGPoint(x: header.frame.width - resultNumber.frame.width - 10, y: searchResult.frame.origin.y)
        header.addSubview(resultNumber)
        
        let line = UIView.init(frame: CGRect(x: 0, y: searchResult.y + searchResult.frame.height + 10, width: header.frame.width, height: 0.5))
        line.backgroundColor = UIColor.DarkGrayAlpha
        header.addSubview(line)
        
        header.frame.size.height = line.y + line.frame.height
        return header
    }

    func clearFilters()
    {
        mCurrentComplexName = ""
        mDelegate?.filtersChanged(filters: nil)
    }

    func getDataForCellAtIndexPath(indexPath: IndexPath) -> NSArray
    {
        var state = 1
        var name = ""
        var address = ""
        var returnArray: NSArray = []
        if mTransits == nil
        {
            var complex: Complex = mSearchResultComplexes.object(at: indexPath) as! Complex
            state = Constant.notNilNum(num: Int(complex.workState))
            name = Constant.notNilStr(str: complex.name)
            address = Constant.notNilStr(str: complex.placeName)
            returnArray = [state, name, address]
        }
        else
        {
            do
            {
                if indexPath.row != 0
                {
                    returnArray = try throwTrue(state: state, name: name, address: address)
                }
                else
                {
                    returnArray = try throwFalse(indexPath: indexPath, state: state, name: name, address: address)
                    
                }
                
            }
            catch
            {
                name = "Нет данных"
                address = "Нет данных"
                returnArray = [state, name, address]
            }
            self.view.endEditing(true)
        }
        return returnArray
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        do {
            try trySearchBar(searchBar: searchBar, searchText: searchText)
        }
        catch
        {
            
        }
    }
    
    func trySearchBar(searchBar :UISearchBar, searchText: String) throws
    {
        var subString = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        subString.stringWithoutDoubleSpaces()
        let firstRegex: NSRegularExpression = try NSRegularExpression(pattern:  "[а-яА-Я]{1}[0-9]{3}[а-яА-Я]{2}[0-9]{2,3}$", options: [])
        let firstMathces: NSArray = firstRegex.matches(in: subString, options: [], range: NSRange(location: 0, length: subString.count) ) as NSArray
        let secondRegex: NSRegularExpression = try NSRegularExpression(pattern: "[а-яА-Я]{2}[0-9]{3}[а-яА-Я]{1}[0-9]{2,3}$", options: [])
        
        let secondMathes: NSArray = secondRegex.matches(in: subString, options: [], range: NSRange(location: 0, length: subString.count)) as NSArray
        
        let defaults = UserDefaults.standard
        let searchEnabled = defaults.bool(forKey: "\(Constant.searchEnabled)")
        defaults.synchronize()
        
        var keyType: UIReturnKeyType!
        var keyBoardtype: UIKeyboardType!
        
        if !searchEnabled || (firstMathces.count == 0) && (secondMathes.count == 0)
        {
            mTransits = nil
            mSearchResultComplexes = CoreDataStack.sharedInstance.getComplexesByNameOrAddress(nameOrAddress: subString)!
            mSearchResult.setFetchController(controller: mSearchResultComplexes, withDelegate: false)
            
            mTransitLoadingIndicator.stopAnimating()
            
            keyType = .done
            keyBoardtype = .default
        }
        else
        {
            keyType = .search
            keyBoardtype = .numbersAndPunctuation
        }
        let startIndex = searchText.dropLast()
        let decimalCharacters = CharacterSet.decimalDigits.inverted
        let decimalRange = startIndex.rangeOfCharacter(from: decimalCharacters)
        
        if searchText.count > 0 && decimalRange == nil
        {
            keyBoardtype = .numbersAndPunctuation
        }
        if searchBar.returnKeyType != keyType
        {
            searchBar.returnKeyType = keyType
            searchBar.keyboardType = keyBoardtype
            searchBar.reloadInputViews()
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
        
        mSearchResult.update()
        var search = subString.count == 0 ? false : true
        mScroll.isHidden = search
        mSearchResult.isHidden = !search
        mTypeWorkStates.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.mSearchResult.alpha = search == false ? 0 : 1
            self.mScroll.alpha = search != false ? 0 : 1
            
        } completion: { _ in
            if search == false
            {
                self.mCurrentComplexName = ""
            }
            self.mTypeWorkStates.removeFromSuperview()
        }
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.text?.count != 0
        {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if mSearchBar.text == " "
        {
            mSearchBar.text = mCurrentSearchString
        }
        mSearchTag.isHidden = true
        mFilters.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.mFilters.alpha = 1
            searchBar.frame.size.width = self.mPanel.frame.width - 15
        }
        if searchBar.text?.count == 0
        {
            searchBar.setShowsCancelButton(true, animated: true)
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.returnKeyType == UIReturnKeyType.search
        {
            let subString = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            subString?.stringWithoutDoubleSpaces()
            
            mSearchResult.setArray(array: [])
            mSearchResult.update()
            self.view.endEditing(true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        mSearchBar.text = ""
        mSearchTag.isHidden = true
        self.clearFilters()
        self.hideFilters(shouldShowScrollView: true)
    }
    
    
    func throwTrue(state: Int, name: String, address: String) throws -> NSArray
    {
        var state = state
        var name = name
        var address = address
        let firstTransit:NSDictionary = mTransits[1] as! NSDictionary
        
        let lastTransit:NSDictionary = mTransits.lastObject as! NSDictionary
        state = 3
        name = "Маршрут за последние 24 часа"
        address = String(format: "%@\n\n↓\n\n%@", arguments: [Constant.notNilStr(str: firstTransit["cameraPlace"] as? String), Constant.notNilStr(str: lastTransit["cameraPlace"] as? String)])
        return [state, name, address]
    }
    
    func throwFalse(indexPath:IndexPath, state: Int, name: String, address: String) throws -> NSArray
    {
        let state = state
        var name = name
        var address = address
        let transit: NSDictionary = mTransits[indexPath.row] as! NSDictionary
        let date = Date(timeIntervalSince1970: TimeInterval(transit["checkTime"] as! Int64 / 1000))
        //        (timeIntervalSince1970: transit["checkTime"] as! Int64 / 1000)
        
        name = Date.stringFromDate(date: date, pattern: "dd.MM.yyyy HH:mm:ss")
        address = Constant.notNilStr(str: transit["cameraPlace"] as? String)
        return [state, name, address]
    }
    
    
    
    @objc func showLogOutAlert()
    {
        let alert = UIAlertController(title: "Вы уверены, что хотите выйти?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler:
                                        {_ in
                                            Networking.sharedInstance.closeSession(params: [:])
                                            {(result) in
                                                switch result {
                                                
                                                case .Success(let _):
                                                    let defaults = UserDefaults.standard
                                                    defaults.setValue(false, forKey: Constant.dataBaseCreated)
                                                    defaults.synchronize()
                                                    UserDefaults.standard.set(true, forKey: "logout")
                                                    UserDefaults.standard.set(false, forKey: "saved")
                                                    
                                                    UserDefaults.standard.synchronize()
                                                    CoreDataStack.sharedInstance.clearData()
                                                    Networking.sharedInstance.sessionToken = ""
                                                    UserDefaults.standard.set(false, forKey: "saved")
                                                    UserDefaults.standard.set(false, forKey: "change")
                                                    UserDefaults.standard.set(false, forKey: "rewritePin")
                                                    UserDefaults.standard.set(true, forKey: Constant.registered)
                                                    UserDefaults.standard.set(false, forKey: Constant.dataBaseCreated)
                                                    UserDefaults.standard.set(true, forKey: "afterBlackOut")
                                                    let secItemClasses = [kSecClassGenericPassword,
                                                                          kSecClassInternetPassword,
                                                                          kSecClassCertificate,
                                                                          kSecClassKey,
                                                                          kSecClassIdentity]
                                                    for secItemClass in secItemClasses {
                                                        let dictionary = [kSecClass as String:secItemClass]
                                                        SecItemDelete(dictionary as CFDictionary)
                                                    }
                                                    
                                                    self.performSegue(withIdentifier: "unwindSegue", sender: nil)
                                                    break
                                                    
                                                case .Error( _):
                                                    
                                                    self.view.isUserInteractionEnabled = true
                                                    break
                                                case .NetworkError( _):
                                                    
                                                    self.view.isUserInteractionEnabled = true
                                                    break
                                                case .LostConnection( _):
                                                    
                                                    self.view.isUserInteractionEnabled = true
                                                    break
                                                case .SessionTimeOut( _):
                                                    
                                                    self.view.isUserInteractionEnabled = true
                                                    break
                                                case .nilResponse( _):
                                                    
                                                    self.view.isUserInteractionEnabled = true
                                                    break
                                                    
                                                }
                                            }
                                        }))
        
        self.present(alert, animated: true)
    }
    
    
    
    
    
    override func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.mSearchResult.frame.size.height == mScroll.frame.size.height {
                self.mSearchResult.frame.size.height = scrollHeight - keyboardSize.height + (self.tabBarController?.tabBar.frame.height)!
                self.mScroll.frame.size.height =  scrollHeight - keyboardSize.height + (self.tabBarController?.tabBar.frame.height)! - 15
            }
        }
    }
    
    override func keyboardWillHide(notification: NSNotification)
    {
        self.mSearchResult.frame.size.height = scrollHeight
        self.mScroll.frame.size.height = scrollHeight
    }
}

