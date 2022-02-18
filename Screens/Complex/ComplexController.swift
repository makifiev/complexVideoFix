//
//  ComplexController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.08.2021.
//

import Foundation
import UIKit
import GoogleMapsUtils
import CoreData
import Kingfisher

protocol ComplexControllerDelegate: AnyObject {
    func complexDidHide()
    func cameraWillShow(camera: Camera)
    func cameraDidHide()
    func complexOffsetDidChange(offset: Float)
}

class ComplexController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, GalleryViewDelegate, UIContextMenuInteractionDelegate
{
     
    weak var mDelegate: ComplexControllerDelegate?
    
    var mComplex: Complex!
    var mCameras: NSArray!
    var mTransits: NSArray!
    
    var mScroll: UIScrollView!
    var mSegmentedControl: UISegmentedControl!
    var mBackGround:UIView!
    
    var mShowStreetView: UIBarButtonItem!
    var mShowTransits:UIBarButtonItem!
    var mShowMap: UIBarButtonItem!
    
    var mInformation = UIScrollView()
    var mCamera = UIScrollView()
    var mCameraPages = UIPageControl()
    
    var mTransitGellery: GalleryView!
    
    var mHeight: Float = 0.0
    var myOffset: Float = 0.0
    
    var mCurrentCamera: Int = 0
    
    var mIsDraft: Bool!
    var mShowingStreetView: Bool!
    var mHasCoordinate: Bool!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mShowingStreetView = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        if mHasCoordinate && !mShowingStreetView
        {
            mDelegate?.cameraDidHide()
            mDelegate?.complexDidHide()
        }
    }
    
    init(withComplex:Complex)
    {
        super.init(nibName: nil, bundle: nil)
        mComplex = withComplex
        mCameras = CoreDataStack.sharedInstance.getCamerasInComplex(complex: Int(mComplex.id))
        mIsDraft = mComplex.state == Constant.draft
        mHasCoordinate = (Int(mComplex.lat) != 0)
        
        if UserDefaults.standard.integer(forKey: Constant.showTabBarButtons) == 1
        {
            self.addTabBatButtons()
        }
        else
        {
            NotificationCenter.default.addObserver(self, selector: #selector(self.addTabBatButtons), name: Notification.Name(Constant.dataBaseUpdated), object: nil)
        }
       
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc func addTabBatButtons()
    {
        if mHasCoordinate
        {
            mShowStreetView = UIBarButtonItem(image: UIImage(named: "streetview-toggle"), style: .done, target: self, action: #selector(showStreetView))
            self.navigationItem.setRightBarButton(mShowStreetView, animated: true)
        } 
        mShowTransits = UIBarButtonItem(image: UIImage(named: "gallery-toggle"), style: .done, target: self, action: #selector(showTransits))
        mShowMap = UIBarButtonItem(image: UIImage(named: "map-toggle"), style: .done, target: self, action: #selector(removeTransits))
    }
    
    override func loadView() {
        
        self.navigationItem.title = "КВФ \(mComplex.name ?? "")\(mIsDraft ? " Черновик" : "")"
        
        self.view = UIView(frame: Constant.mainFrame)
        self.view.backgroundColor = .clear
        self.edgesForExtendedLayout = []
        
        mScroll = UIScrollView(frame: self.view.frame)
        print(CGFloat(Constant.complexPanelOffset))
        mScroll.contentInset = UIEdgeInsets(top: mHasCoordinate ? CGFloat(Constant.complexPanelOffset) : 0, left: 0, bottom: CGFloat(Constant.iPhoneXTabBarCoefficient * 3), right: 0)
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: mScroll.frame.height + Constant.navigationBarHeight(navigationController: self.navigationController!))
        mScroll.backgroundColor = .clear
        
        mScroll.showsVerticalScrollIndicator = false
        mScroll.delaysContentTouches = false
        mScroll.delegate = self
        self.view.addSubview(mScroll)
        
        if Constant.IOS11
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
            mScroll.setBlurWithoutStyle(size: CGSize(width: self.view.frame.width, height: mScroll.contentSize.height))
        }
        let itemTitles = ["Комплекс", "Камеры \(mCameras.count)"]
        
        mSegmentedControl = UISegmentedControl(items: itemTitles)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            mSegmentedControl.frame = CGRect(x: 15, y: 14, width: 282, height: 30)
            mSegmentedControl.center.x = mScroll.center.x
        }
        else
        {
            mSegmentedControl.frame = CGRect(x: 15, y: 14, width: mScroll.frame.width - 30, height: 30)
        }
       
        mSegmentedControl.tintColor = UIColor.MediumGray
        mSegmentedControl.selectedSegmentIndex = 0
        mSegmentedControl.addTarget(self, action: #selector(segmentedControlPressed), for: .valueChanged)
        mScroll.addSubview(mSegmentedControl)
        
        self.addInforamtion()
        self.addCamera()
        
        if mHasCoordinate && mCameras.count == 1
        {
            mDelegate?.cameraWillShow(camera: mCameras[0] as! Camera)
        }
    }
    
    func addInforamtion()
    {
        print(mScroll.frame.height)
        let y = mSegmentedControl.frame.origin.y + mSegmentedControl.frame.height
        mInformation = UIScrollView()
        mInformation.frame = CGRect(x: 0, y: y, width: mScroll.frame.width, height: mScroll.frame.height - (y * 2))
        mInformation.backgroundColor = UIColor.clear
        mInformation.showsVerticalScrollIndicator = false
        mInformation.delaysContentTouches = false
        mInformation.isScrollEnabled = false
        mInformation.contentSize = CGSize(width: 0, height: 14)
        mScroll.addSubview(mInformation)
        
        self.addInformationViews()
    }
    func addInformationViews()
    {
        let sertIfEndDate = Date.stringFromDate(dateString: mComplex.serfiffEndDate ?? "", formats: ["yyyy-MM-dd","dd/MM/yyyy"], enLocale: false)
        self.addViolations(info: CoreDataStack.sharedInstance.getViolationsForComplex(complex: Int(mComplex.id)), view: mInformation)
        self.addMainInformation(info: [["Адрес", mComplex.placeName ?? "Нет данных"],
                                       ["Работоспособность", mComplex.workTitle ?? "", "\(mComplex.workState)"],
                                       ["Причины неработоспособности", Constant.notNil(obj: mComplex.unworkReasons as AnyObject)],
                                       ["Модель", Constant.notNil(obj: mComplex.model as AnyObject)],
                                       ["Сертификат поверки до", sertIfEndDate != "" ? sertIfEndDate : "Нет данных"]],
                                view: mInformation)
        self.addSummary(info: [["Эффективность:", Constant.notNil(obj: mComplex.summaryEfficiency as AnyObject)],
                               ["Проезды:", Constant.notNil(obj: mComplex.summaryPassages as AnyObject)],
                               ["Нарушения:", Constant.notNil(obj: mComplex.summaryViolations as AnyObject)],
                               ["Постановления:", Constant.notNil(obj: mComplex.summaryResolutions as AnyObject)]], view: mInformation)
    }
    
    func addCamera()
    {
        let y = mSegmentedControl.frame.origin.y + mSegmentedControl.frame.height
        mCamera = UIScrollView()
        mCamera.frame = CGRect(x: 0, y: y, width: mScroll.frame.width, height: mScroll.frame.height - (y * 2))
        mCamera.backgroundColor = UIColor.clear
        mCamera.showsHorizontalScrollIndicator = false
        mCamera.delaysContentTouches = false
        mCamera.isPagingEnabled = true
        mCamera.isHidden = true
        mCamera.delegate = self
        mScroll.addSubview(mCamera)
        
        self.addCameraViews()
        if mCameras.count > 1
        {
            mCameraPages = UIPageControl()
            mCameraPages.currentPageIndicatorTintColor = .Blue
            mCameraPages.pageIndicatorTintColor = .BlueAlpha
            mCameraPages.numberOfPages = mCameras.count
            mCameraPages.isUserInteractionEnabled = false
            mCameraPages.isHidden = true
            mCameraPages.sizeToFit()
            mCameraPages.frame = CGRect(x: 0, y: y, width: mCameraPages.frame.width + 30, height: 28)
            mCameraPages.center.x = mScroll.frame.width / 2
            mScroll.addSubview(mCameraPages)
        }
    }
    
    func addCameraViews()
    {
        for i in 0..<mCameras.count
        {
            let camera: Camera = mCameras[i] as! Camera
            let scroll = UIScrollView()
            scroll.frame = CGRect(x: mCamera.frame.width * CGFloat(i), y: 0, width: mCamera.frame.width, height: mCamera.frame.height)
            scroll.backgroundColor = .clear
            scroll.showsVerticalScrollIndicator = false
            scroll.delaysContentTouches = false
            scroll.isScrollEnabled = false
            scroll.contentSize = CGSize(width: 0, height: mCameras.count > 1 ? 27 : 14)
            mCamera.addSubview(scroll)
            self.addViolations(info: CoreDataStack.sharedInstance.getViolationsForCamera(camera: Int(camera.id)), view: scroll)
            self.addMainInformation(info: [["Идентификатор", Constant.notNil(obj: camera.name as AnyObject)],
                                           ["Назначение", Constant.notNil(obj: camera.purposeTypeName as AnyObject)],
                                           ["Направление движения", camera.directionName ?? "Нет данных"],
                                           ["Работоспособность", Constant.notNil(obj: camera.workTitle as AnyObject), Constant.notNil(obj: camera.workState as AnyObject)],
                                           ["Причины неработоспособности", Constant.notNil(obj: camera.unworkReasons as AnyObject)]], view: scroll)
            self.addSummary(info: [["Эффективность:", Constant.notNil(obj: camera.summaryEfficiency as AnyObject)],
                                   ["Проезды:", Constant.notNil(obj: camera.summaryPassages as AnyObject)],
                                   ["Нарушения:", Constant.notNil(obj: camera.summaryViolations as AnyObject)],
                                   ["Постановления", Constant.notNil(obj: camera.summaryResolutions as AnyObject)]],
                            view: scroll)
        }
        mCamera.contentSize = CGSize(width: mCamera.frame.width * CGFloat(mCameras.count), height: mCamera.frame.height)
    }
    
    func addViolations(info: NSArray, view: UIScrollView)
    {
        if info.count != 0
        {
            let backGround: UIView = UIView(frame: CGRect(x: 0, y: view.contentSize.height, width: view.frame.width, height: 40))
            backGround.backgroundColor = UIColor.GrayApha
            view.addSubview(backGround)
            
            let violations: UILabel = UILabel()
            violations.labelWithFrame(frame: .zero, colors: [UIColor.darkGray, UIColor.clear])
            violations.text = "УТВЕРЖДЕННЫЕ НАРУШЕНИЯ"
            violations.font = Constant.setMediumFont(size: 12)
            violations.sizeToFit()
            violations.setPosition = CGPoint(x: 10, y: backGround.frame.height - violations.frame.height - 6)
            backGround.addSubview(violations)
            
            var y = backGround.frame.origin.y + backGround.frame.height
            
            let images:NSMutableArray = []
            let ids:NSMutableArray = []
            for i in 0..<info.count
            {
                let violation: Violation = info[i] as! Violation
                var imageName: String!
                if violation.violValueUnit == "км/ч"
                {
                    imageName = "icon-id-speed-\(violation.violValueLimit != 0 ? violation.violValueLimit : 5)"
                }
                else
                {
                    imageName = "icon-id-\(violation.violId)"
                }
                if !images.contains(imageName!)
                {
                    images.add(imageName)
                    ids.add(violation.id)
                }
            }
            
            let row = Constant.iPhone6Plus ? 5 : 4
            for i in 0..<images.count
            {
                let imageName = images[i]
                let violationId = ids[i]
                let icon = UIImageView(image: UIImage(named: imageName as! String))
                icon.frame.size = CGSize(width: 70, height: 70)
                let firstElement = CGFloat((Int(view.frame.width) - 20) / row)
                let SecondElement = CGFloat(i - row * Int(ceil(Double(i / row))))
                let ThirdElement = (((view.frame.width - 20) / CGFloat(row)) - icon.frame.width) / 2
                let fourthElement = (icon.frame.height) * ceil(CGFloat(i / row)) + (y + 20)
                let Result = firstElement * SecondElement + ThirdElement
                icon.setPosition = CGPoint(x: 10.0 + Result, y: fourthElement)
                icon.tag = violationId as! Int
                icon.backgroundColor = .clear
                icon.layer.cornerRadius = 10
                icon.layer.masksToBounds = false
                view.addSubview(icon)
                if Constant.touch3D(controller: self)
                {
                    icon.isUserInteractionEnabled = true
                    if #available(iOS 13.0, *) {
                        let interaction = UIContextMenuInteraction(delegate: self)
                        icon.addInteraction(interaction)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                }
                if i == images.count - 1
                {
                    y = icon.frame.origin.y + icon.frame.height
                }
            }
            y += 20
            view.contentSize = CGSize(width: view.frame.width, height: y)
        }
    }
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: {
                                            suggestedActions in
                                            
                                            let tag = interaction.view!.tag
                                            let violation = CoreDataStack.sharedInstance.getViolations(id: tag)
                                            var imageName: String?

                                            if violation?.violValueUnit == "км/ч"
                                            {
                                                imageName = "icon-id-speed-\((violation!.violValueLimit != nil) ? violation!.violValueLimit : 5)-large"
                                            }
                                            else
                                            {
                                                imageName = "icon-id-\(violation!.violId)-large"
                                            }
                                            interaction.view?.backgroundColor = .clear
                                             
                                            let inspectAction =
                                                UIAction(title: NSLocalizedString("\(violation!.violId). \(violation!.violName ?? "")", comment: ""),
                                                         image: UIImage(named: imageName!)) { action in
                                                }
                                            
                                            return UIMenu(title: "", children: [inspectAction])
                                          })
    }
    
//    @available(iOS 13.0, *)
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        let view = interaction.view!
//        view.backgroundColor = .white
//        view.setBlur()
//
//        let tag = interaction.view!.tag
//        let violation = CoreDataStack.sharedInstance.getViolations(id: tag)
//        var imageName: String?
//
//        if violation?.violValueUnit == "км/ч"
//        {
//            imageName = "icon-id-speed-\((violation!.violValueLimit != nil) ? violation!.violValueLimit : 5)-large"
//        }
//        else
//        {
//            imageName = "icon-id-\(violation!.violId)-large"
//        }
//
//        let imageView = UIImageView(image: UIImage(named: imageName!))
//        imageView.frame.size = CGSize(width: 70, height: 70)
//        imageView.backgroundColor = .clear
//        view.addSubview(imageView)
//        return UITargetedPreview(view: view)
//    }
    
    func addMainInformation(info: NSArray, view: UIScrollView)
    {
        let backGround:UIView = UIView(frame: CGRect(x: 0, y: view.contentSize.height, width: view.frame.width, height: 40))
        backGround.backgroundColor = UIColor.GrayApha
        view.addSubview(backGround)
        
        let mainInformation = UILabel()
        mainInformation.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        mainInformation.text = "ОСНОВНЫЕ СВЕДЕНИЯ"
        mainInformation.font = Constant.setMediumFont(size: 12)
        mainInformation.sizeToFit()
        mainInformation.setPosition = CGPoint(x: 10, y: backGround.frame.height - mainInformation.frame.height - 6)
        backGround.addSubview(mainInformation)
        
        var y = backGround.frame.origin.y + backGround.frame.height
        for i in 0..<info.count
        {
            let array = info[i] as! NSArray
            let secondElement = array[1] as? String
            if array[0] as! String == "Причины неработоспособности" && secondElement?.count == 0
            {
                continue
            }
            var x = 10
            let title = UILabel()
            title.labelWithFrame(frame: CGRect(x: x, y: Int(y) + 20, width: 0, height: 0), colors: [UIColor.blue, UIColor.clear])
            title.text = array[0] as? String
            title.font = Constant.setMediumFont(size: 17)
            title.sizeToFit()
            view.addSubview(title)
            
            var state = UIView()
            if array[0] as! String == "Работоспособность"
            {
                state = UIView()
                state.frame = CGRect(x: 10, y: 0, width: 10, height: 10)
                
                var intElement: Int!
                if let element = array[2] as? NSString
                {
                    intElement = Int(element as String)
                }
                else if let element = array[2] as? Double
                {
                    intElement = Int(element)
                }
                state.backgroundColor = Constant.colors[intElement]
                state.layer.cornerRadius = state.frame.width / 2
                view.addSubview(state)
                
                x = Int(state.frame.origin.x + state.frame.width + 8)
            }
            
            let value = UILabel()
            value.labelWithFrame(frame: CGRect(x: x, y: Int(title.frame.origin.y + title.frame.height) + 5, width: Int(view.frame.width) - (x + 10), height:  0), colors: [UIColor.DarkGray, UIColor.clear])
            let array1 = array[1] as? String ?? ""
            value.attributedText = array1.attributedStringWithLineSpacing(lineSpacing: 2)
            value.font = Constant.setMediumFont(size: 14)
            value.sizeToFit()
            view.addSubview(value)
            
            state.frame.origin.y = value.frame.origin.y + 4
            y = value.frame.origin.y + value.frame.height
        }
        y += 20
        view.contentSize = CGSize(width: view.frame.width, height: y)
    }
    
    func addSummary(info: NSArray, view: UIScrollView)
    {
        let backGround = UIView(frame: CGRect(x: 0, y: view.contentSize.height, width: view.frame.width, height: 40))
        backGround.backgroundColor = UIColor.GrayApha
        view.addSubview(backGround)
        
        let summary = UILabel()
        summary.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        summary.text = "Сводка"
        summary.font = Constant.setMediumFont(size: 12)
        summary.sizeToFit()
        summary.setPosition = CGPoint(x: 10, y: backGround.frame.height - summary.frame.height - 6)
        backGround.addSubview(summary)
        
        var y = backGround.frame.origin.y + backGround.frame.height
        
        for i in 0..<info.count
        {
            let array = info[i] as! NSArray
            let summary = (array[1] as? String ?? "").split(separator: "/") as [Any]
            let value1 = Int(summary[safe: 0] as? String ?? "")
            var value2 = 0
            if summary.count >= 2
            {
                value2 = Int("\(summary[1])")!
            }
            
            let percent = (value1 != 0 && value2 != 0) ? value1 ?? 0 / value2 * 100 : 0
            
            var stateColor = UIColor.clear
            if percent < 30
            {
                stateColor = UIColor.Red
            }
            else if percent > 60
            {
                stateColor = UIColor.Green
            }
            else
            {
                stateColor = UIColor.Orange
            }
            let state = UIView()
            state.frame = CGRect(x: 10, y: 0, width: 10, height: 10)
            state.backgroundColor = stateColor
            state.layer.cornerRadius = state.frame.width / 2
            view.addSubview(state)
            
            let title = UILabel()
            title.labelWithFrame(frame: CGRect(x: state.frame.origin.x + state.frame.width + 8, y: y + 20, width: 0, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
            title.text = array[0] as? String
            title.font = Constant.setMediumFont(size: 17)
            title.sizeToFit()
            view.addSubview(title)
            
            state.center.y = title.center.y
            
            let value = UILabel()
            value.labelWithFrame(frame: CGRect(x: 10 + view.frame.width / 2, y: 0, width: view.frame.width / 2 - 20, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
            value.attributedText = "\(value1 ?? 0) из \(value2) \(percent)%".attributedStringWithLineSpacing(lineSpacing: 2)
            value.font = Constant.setMediumFont(size: 14)
            value.sizeToFit()
            value.center.y = title.center.y
            view.addSubview(value)
            
            y = title.frame.origin.y + title.frame.height
        }
        y += 40
        view.contentSize = CGSize(width: view.frame.width, height: y)
    }
    
    @objc func segmentedControlPressed(segment: UISegmentedControl)
    {
        let view: UIView = segment.selectedSegmentIndex == 0 ? mCamera : mInformation
        let nextView: UIView = segment.selectedSegmentIndex == 0 ? mInformation : mCamera
        
        view.isHidden = true
        nextView.isHidden = false
        
        let isCameraNext = nextView.isEqual(mCamera)
        if mHasCoordinate && mCameras.count > 1
        {
            if isCameraNext
            {
                mDelegate?.cameraWillShow(camera: mCameras[mCurrentCamera] as! Camera)
            }
            else
            {
                mDelegate?.cameraDidHide()
            }
        }
        else if mCameras.count == 0
        {
                mScroll.contentSize.height = self.view.frame.size.height / 2
                mScroll.isScrollEnabled = false
        }
        mCameraPages.isHidden = !isCameraNext
        if mTransitGellery != nil
        {
            if isCameraNext
            {
                self.showTransits()
               
            }
            else
            {
                self.hideTransits(shouldRemove: false)
            }
        }
        self.navigationItem.setRightBarButton(isCameraNext ? (mTransitGellery != nil ? mShowMap : mShowTransits) : mShowStreetView, animated: true)
    }
    @objc func showTransits()
    {
        if Connectivity.isConnectedToInternet()
        {
            if  mCameras.count != 0
            {
            if mTransitGellery == nil
            {
                mTransitGellery = GalleryView()
                mTransitGellery.alpha = 0
                mTransitGellery.mAutoScroll = true
                mTransitGellery.mAutoUpdate = true
                mTransitGellery.mDelegate = self
                mScroll.addSubview(mTransitGellery)
                mScroll.sendSubviewToBack(mTransitGellery)
                
                self.loadTransits()
            }
            mScroll.contentInset = UIEdgeInsets(top: mTransitGellery.frame.height, left: 0, bottom: 0, right: 0)
            UIView.animate(withDuration: 0.3) {
                self.mScroll.contentOffset = CGPoint(x: 0, y: -self.mTransitGellery.frame.height)
            } completion: { (f: Bool) in
                self.mTransitGellery.frame.origin.y = -self.mTransitGellery.frame.height
                UIView.animate(withDuration: 0.3) {
                    if self.mScroll.contentOffset.y != -self.mTransitGellery.frame.height
                    {
                        self.mScroll.contentOffset = CGPoint(x: 0, y: -self.mTransitGellery.frame.height)
                    }
                    self.mTransitGellery.alpha = 1
                } completion: { (f: Bool) in
                    self.changeContentOffset()
                }
            }
            self.navigationItem.setRightBarButtonItems([mShowMap], animated: true)
            }
           
        }
        
    }
    func loadTransits()
    {
        mTransitGellery.clearWithCompletion(completionFunc: {
            let i = self.mTransitGellery.tag + 1
            self.mTransitGellery.tag = i
            let camera = self.mCameras[self.mCurrentCamera] as! Camera
            Networking.sharedInstance.loadTransitsForCamera(params: [:], camera: Int(camera.id))
            {(result) in
                switch result {
                case .Success(let transits):
                    
                    if self.mTransitGellery.tag == i
                    {
                        self.mTransits = transits
                        self.mTransitGellery.loadImages(count: transits.count)
                    }
                    break
                case .Error( _):
                    self.mTransitGellery.loadImages(count: 0)
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
            
            
        }, animated: true)
    }
    @objc func removeTransits()
    {
        self.hideTransits(shouldRemove: true)
        self.navigationItem.setRightBarButtonItems([mShowTransits], animated: true)
    }
    
    func hideTransits(shouldRemove: Bool)
    {
        UIView.animate(withDuration: 0.3) {
            self.mTransitGellery.alpha = 0
        } completion: { (f: Bool) in
            if shouldRemove
            {
                self.mTransitGellery.removeFromSuperview()
                self.mTransitGellery = nil
            }
            
            let offset: Int = self.mHasCoordinate ? Constant.complexPanelOffset : 0
            UIView.animate(withDuration: 0.3) {
                self.mScroll.contentOffset = CGPoint(x: 0, y: -offset)
            } completion: { (f: Bool) in
                self.mScroll.contentInset = UIEdgeInsets(top: CGFloat(offset), left: 0, bottom: 0, right: 0)
                self.changeContentOffset()
            }
            
        }
        
    }
    @objc func showStreetView()
    {
        mShowingStreetView = true
        if mComplex != nil
        {
               if mComplex.id != 0
            {
        let streetViewController = StreetViewController.init(withComplex: mComplex)
        self.navigationController?.pushViewController(streetViewController, animated: true)
            }
            else
            {
                showStreetViewAlert()
            }
        }
        
    }
    
    @objc func showStreetViewAlert() {
        
        let alert = UIAlertController(title: "Ошибка", message: "Нет Данных", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
        
//        alert.addAction(UIAlertAction(title: "Обычный", style: .default, handler:
//                                        {_ in
//                                            self.mapView.mapType = .normal
//                                            let defaults = UserDefaults.standard
//                                            defaults.setValue(0, forKey: Constant.mapType)
//                                            defaults.synchronize()
//                                        }))
//        alert.addAction(UIAlertAction(title: "Спутник", style: .default, handler:
//                                        {_ in
//                                            self.mapView.mapType = .hybrid
//                                            let defaults = UserDefaults.standard
//                                            defaults.setValue(1, forKey: Constant.mapType)
//                                            defaults.synchronize()
//                                        }))

        self.present(alert, animated: true)
    }
    
    func numberFromArrayOfDicts(index: Int, key: String, array: NSArray) throws -> Int
    {
        let element:AnyObject =  array[index] as AnyObject
        let guardNumber = element[key] as! Int
        return guardNumber
    }
    
    func galleryImageAtIndex(index: Int, success: @escaping (UIImage?) -> Void, failure: @escaping(String) -> Void) {
        if mTransits.count != 0
        {
            var number = 0
            do
            {
                number = try numberFromArrayOfDicts(index: index, key: "checkId", array: mTransits)
            }
            catch
            {
                
            }
            
            Networking.sharedInstance.loadTransitPhoto(transit: number,
                                                       success: success,
                                                       failure: failure)
        }
    }
    
    
    func nullToNil(value : Any?) -> Any? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    func throwsGetItems(key: String, index: Int) throws -> Any?
    {
        let mTransitsItemAtIndex:NSDictionary = mTransits[index] as! NSDictionary
        var getObject = mTransitsItemAtIndex.object(forKey: key)
        if getObject is String
        {
            let string:String = getObject as! String
            if string.count == 0
            {
                getObject = nil
            }
        }
        return nullToNil(value: getObject)
        
    }
    func galleryCaptionsAtIndex(index: Int) -> NSArray {
        var date = ""
        var regnum = ""
        if mTransits.count != 0
        {
            do
            {
                date = try Date.stringFromDate(date: Date(timeIntervalSince1970:throwsGetItems(key: "checkDate", index: index) as! Double / 1000), pattern: "dd.MM.yyyy HH:mm")
                regnum = try throwsGetItems(key: "regnum", index: index) as! String
            }
            catch
            {
                date = "Нет данных"
                regnum = "Нет данных"
            }
        }
        return[date != "" ? date : "Нет данных", regnum != "" ? regnum : "Нет данных"]
    }
    
    func galleryReloadData() {
        let i = mTransitGellery.tag + 1 as Int
        mTransitGellery.tag = i
        
        let camera: Camera = mCameras[mCurrentCamera] as! Camera
        
        Networking.sharedInstance.loadTransitsForCamera(params: [:], camera: Int(camera.id))
        {(result) in
            switch result {
            
            case .Success(let transits):
                
                if self.mTransitGellery.tag == i
                {
                    self.mTransits = transits
                    self.mTransitGellery.updateImages()
                }
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeContentOffset()
    {
        if mInformation.isHidden
        {
            let array = mCamera.subviews
            let scroll = array[mCurrentCamera] as! UIScrollView
            for i in 0..<array.count
            {
                let view = array[i]
                if view is UIScrollView
                {
                    let scrollView = view as! UIScrollView
                    scrollView.contentOffset = scroll.contentOffset
                }
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == mScroll
        {
            let array = (mInformation.isHidden ? mCamera.subviews : [mInformation]) as NSArray
            mHeight = 0
            for i in 0..<array.count
            {
                let view = array[i]
                if view is UIScrollView
                {
                    let view = view as! UIScrollView
                    mHeight = max(mHeight, Float(view.contentSize.height))
                }
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mScroll
        {
            let view = mInformation.isHidden ? mCamera.subviews[mCurrentCamera] : mInformation
            if view is UIScrollView
            {
                let view = view as! UIScrollView
                let height = view.frame.height
                if (scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height || myOffset > 0) && (scrollView.contentOffset.y + scrollView.frame.height < scrollView.contentSize.height || myOffset < mHeight - Float(height))
                {
                    var y = scrollView.contentSize.height - scrollView.frame.height
                    view.contentOffset = CGPoint(x: view.contentOffset.x, y: view.contentOffset.y + scrollView.contentOffset.y - y)
                    myOffset = Float(view.contentOffset.y)
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: y)
                    mCameraPages.frame.origin.y = mSegmentedControl.frame.origin.y + mSegmentedControl.frame.height
                    UIView.animate(withDuration: 0.3) {
                        self.mCameraPages.backgroundColor = .WhiteWeakAlpha
                    }
                }
                else if myOffset <= 0
                {
                    view.contentOffset = CGPoint(x: view.contentOffset.x, y: 0)
                    mCameraPages.backgroundColor = .clear
                }
                else if myOffset >= mHeight - Float(height)
                {
                    view.contentOffset = CGPoint(x: view.contentOffset.x, y: CGFloat(mHeight) - height)
                    mCameraPages.frame.origin.y = mSegmentedControl.frame.origin.y + mSegmentedControl.frame.height + scrollView.contentOffset.y - Constant.navigationBarHeight(navigationController: self.navigationController!)
                }
                if mTransitGellery != nil && !mTransitGellery.isHidden && scrollView.contentOffset.y < -(Constant.mainFrame.size.height / 2)
                {
                    let height = -scrollView.contentOffset.y
                    mTransitGellery.frame = CGRect(x: 0, y: -height, width: mTransitGellery.frame.width, height: height)
                }
                else
                {
                    let offset = -(scrollView.contentInset.top + scrollView.contentOffset.y)
                    if mHasCoordinate && offset > 0
                    {
                        mDelegate?.complexOffsetDidChange(offset: Float(offset))
                    }
                }
                if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height
                {
                    scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.height
                }
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == mScroll && mInformation.isHidden
        {
            self.changeContentOffset()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mScroll && mInformation.isHidden
        {
            self.changeContentOffset()
        }
        else if scrollView == mCamera
        {
            let currentCamera = scrollView.contentOffset.x / scrollView.frame.width
            if mCurrentCamera != Int(currentCamera)
            {
                mCurrentCamera = Int(currentCamera)
                if mHasCoordinate
                {
                    mDelegate?.cameraWillShow(camera: mCameras[mCurrentCamera] as! Camera)
                }
                mCameraPages.currentPage = mCurrentCamera
                if mTransitGellery != nil
                {
                    if Connectivity.isConnectedToInternet()
                    {
                        self.loadTransits()
                    }
                    else
                    {
                        removeTransits()
                    }
                }
            }
        }
    }
    override var shouldAutorotate: Bool
    {
        return false
    }
}
