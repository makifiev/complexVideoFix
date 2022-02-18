//
//  ReportBuilderController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 14.11.2021.
//

import Foundation
import UIKit
import CoreData

extension ReportBuilderController
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewPeriod
        {
            return 4
        }
        
        else if pickerView == pickerViewType
        {
            return mArray1.count
        }
        
        else if pickerView == pickerViewClass
        {
            return mArray2.count
        }
        
        else
        {
            return 0
        }
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == pickerViewPeriod
        {
            return array[row]
        }
        else if pickerView == pickerViewType
        {
            return mArray1[row] as? String
        }
        else if pickerView == pickerViewClass
        {
            return mArray2[row] as? String
        }
        else
        {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewPeriod
        {
            mPeriod.text = array[row] != "" ? array[row] : "Не выбрано"
            mPeriod.text = array[row]
            let interval = array[row] == "День" ? Interval.DayInterval : (array[row] == "Неделя" ? Interval.WeekInterval : Interval.MonthInterval)
            let nextDate = Date.dateFromDate(date: Date(), interval: interval)
            
            self.setDate(date: nextDate, textField: mStartDate)
            self.setDate(date: Date(), textField: mEndDate)
        }
        if pickerView == pickerViewType
        {
            mComplexType.text = mArray1[row] as? String
        }
        if pickerView == pickerViewClass
        {
            mComplexClass.text = mArray2[row] as? String
        }
        showCreateReport()
    }
    
    
    func addPicker(pickerView: UIPickerView, textField: UITextField)
    {
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let close = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeView))
        toolbar.setItems([space,close], animated: false)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        textField.inputAccessoryView = toolbar
        textField.inputView = pickerView
        
    }
    
    func addDatePicker(datePicker: UIDatePicker, textField: UITextField)  -> UIDatePicker
    {
        var datePicker = datePicker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }   
        let loc = Locale(identifier: "ru")
        datePicker.locale = loc
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let close = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeView))
        toolbar.setItems([space,close], animated: false)
        textField.inputAccessoryView = toolbar
        return datePicker
    }
    
    
    @objc func closeView()
    {
        self.view.endEditing(true)
    }
    
    @objc func datePickerStartValueChanged()
    {
        mStartDate.text = Date.stringFromDate(date: pickerViewStart.date, pattern: "EEE, dd.MM.yyyy")
        mPeriod.text = "Не выбрано"
        showCreateReport()
    }
    
    @objc func datePickerEndValueChanged()
    {
        mEndDate.text = Date.stringFromDate(date: pickerViewEnd.date, pattern: "EEE, dd.MM.yyyy")
        mPeriod.text = "Не выбрано"
        showCreateReport()
    }
}

class ReportBuilderController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    
    
    let array = ["Не выбрано", "День", "Неделя", "Месяц"]
    var mArray1: NSArray = []
    var mProperty1: String!
    
    var mArray2: NSArray = []
    var mProperty2: String!
    
    var pickerViewPeriod = UIPickerView()
    var pickerViewStart = UIDatePicker()
    var pickerViewEnd = UIDatePicker()
    var pickerViewType = UIPickerView()
    var pickerViewClass = UIPickerView()
    
    
    var mPanel = UIView()
    var mScroll = UIScrollView()
    
    var mPeriod = UITextField()
    var mStartDate = UITextField()
    var mEndDate = UITextField()
    var mComplexType = UITextField()
    var mComplexClass = UITextField()
    
    var mCreateReport = UIButton()
    var mUpdateReport = UIButton()
    var mCreatingView = UIView()
    var mCreatingError = UILabel()
    
    var mToolBar = UIToolbar()
    
    var mReport: Report!
    weak var mDelegate: ReportsDelegate?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mScroll.contentOffset = .zero
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.edgesForExtendedLayout = []
        
        
        
        self.addPanel()
        self.addViews()
        
        let defaults = UserDefaults.standard
        mComplexType.isUserInteractionEnabled = false
        mComplexClass.isUserInteractionEnabled = false
        
            if defaults.bool(forKey: "afterBlackOut") == true
            {
                mComplexType.isUserInteractionEnabled = true
                mComplexClass.isUserInteractionEnabled = true
            }
        
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataBaseUpdated), name: NSNotification.Name(rawValue: Constant.dataBaseUpdated), object: nil)
    }
    
    func addPanel()
    {
        mPanel = UIView()
        mPanel.frame = CGRect(x: -1, y: -1.5, width: self.view.frame.width + 2, height: 66 + CGFloat(Constant.iPhoneNavBarCoefficient))
        mPanel.layer.borderWidth = 0.3
        mPanel.layer.borderColor = UIColor.DarkGrayAlpha.cgColor
        mPanel.setBlur()
        self.view.addSubview(mPanel)
        
        let title = UILabel()
        title.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        title.text = "Состояние системы"
        title.font = Constant.setFontBold(size: 18)
        title.sizeToFit()
        title.center = CGPoint(x: mPanel.frame.width / 2, y: Constant.statusBarHeight + (mPanel.frame.height - Constant.statusBarHeight) / 2)
        mPanel.addSubview(title)
    }
    
    func addViews()
    {
        let backGround = UIView()
        backGround.frame = CGRect(x: 0, y: mPanel.frame.origin.y + mPanel.frame.height, width: self.view.frame.width, height: self.view.frame.height - (mPanel.frame.origin.y + mPanel.frame.height) - CGFloat(Constant.tabBarHeight!) + 5)
        backGround.backgroundColor = .White
        self.view.addSubview(backGround)
        
        mScroll = UIScrollView()
        mScroll.frame = backGround.frame
        mScroll.showsVerticalScrollIndicator = false
        mScroll.delaysContentTouches = false
        self.view.addSubview(mScroll)
        
        self.view.bringSubviewToFront(mPanel)
        
        self.addPeriod(info: [
            ["Период",
             ["День", "Неделя", "Месяц"]
            ],
            ["Начало периода"],
            ["Конец периода"]
        ],
        view: mScroll)
        
        self.addComplexTypes(info: [["Тип КВФ", CoreDataStack.sharedInstance.getComplexTypes(), "name"],
                                    ["Класс КВФ", CoreDataStack.sharedInstance.getComplexClasses(), "name"]],
                             toView: mScroll)
        
        self.addCreateReportViews()
    }
    
    func addPeriod(info: NSArray, view: UIScrollView)
    {
        let background = UIView(frame: CGRect(x: 0, y: view.contentSize.height, width: view.frame.width, height: 40))
        background.backgroundColor = .GrayApha
        view.addSubview(background)
        
        let summary = UILabel()
        summary.labelWithFrame(frame: CGRect.zero, colors: [UIColor.DarkGray, UIColor.clear])
        summary.text = "ПЕРИОД"
        summary.font = Constant.setMediumFont(size: 12)
        summary.sizeToFit()
        summary.setPosition = CGPoint(x: 10, y: background.frame.height - summary.frame.height - 6)
        background.addSubview(summary)
        
        var y = background.frame.origin.y + background.frame.height
        for i in 0..<info.count
        {
            let array = info[i] as! NSArray
            let title = UILabel()
            title.labelWithFrame(frame: CGRect(x: 10, y: y + 20, width: 0, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
            title.text = array[0] as? String
            title.font = Constant.setMediumFont(size: 17)
            title.sizeToFit()
            view.addSubview(title)
            
            
            let value = UITextField()
            value.textFieldWithFrame(frame: CGRect(x: title.frame.origin.x, y: 0, width: view.frame.width - 20, height: 30), font: Constant.setMediumFont(size: 17), colors: [UIColor.Blue, UIColor.clear], placeHolder: "")
            value.center.y = title.center.y
            value.textAlignment = .right
            
            if array[0] as! String == "Период"
            {
                self.addPicker(pickerView: pickerViewPeriod, textField: value)
                pickerViewPeriod.tag = 10
            }
            else
            {
                if i == 1
                {
                    pickerViewStart = addDatePicker(datePicker: pickerViewStart, textField: value)
                    pickerViewStart.tag = 10 + i
                    pickerViewStart.addTarget(self, action: #selector(datePickerStartValueChanged), for: .valueChanged)
                    value.inputView = pickerViewStart
                }
                if i == 2
                {
                    pickerViewEnd = addDatePicker(datePicker: pickerViewEnd, textField: value)
                    pickerViewEnd.tag = 10 + i
                    pickerViewEnd.addTarget(self, action: #selector(datePickerEndValueChanged), for: .valueChanged)
                    value.inputView = pickerViewEnd
                }
            }
            
            
            value.textAlignment = .right
            
            view.addSubview(value)
            
            switch i {
            case 0:
                mPeriod = value
                mPeriod.text = "Не выбрано"
                break
            case 1:
                mStartDate = value
                self.setDate(date: Date(), textField: mStartDate)
                break
            case 2:
                mEndDate = value
                self.setDate(date: Date(), textField: mEndDate)
                break
            default:
                break
            }
            y = value.frame.origin.y + value.frame.height
        }
        y += 20
        view.contentSize = CGSize(width: view.frame.width, height: y)
    }
    
    func addComplexTypes(info: NSArray, toView: UIScrollView)
    {
        let backGround: UIView = UIView(frame: CGRect(x: 0, y: toView.contentSize.height, width: toView.frame.width, height: 40))
        backGround.backgroundColor = UIColor.GrayApha
        toView.addSubview(backGround)
        
        let summary = UILabel()
        summary.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        summary.text = "КВФ"
        summary.font = Constant.setMediumFont(size: 12)
        summary.sizeToFit()
        summary.setPosition = CGPoint(x: 10, y: backGround.frame.height - summary.frame.height - 6)
        backGround.addSubview(summary)
        
        var y = backGround.frame.origin.y + backGround.frame.height
        for i in 0..<info.count
        {
            let array = info[i] as! NSArray
            
//            var names = ["Все"]
//            let array1 = info[i] as? ComplexType
//            let name = array1?.name ?? ""
//            names.append(name)
//            mArray1 = names as NSArray
            
            let title = UILabel()
            title.labelWithFrame(frame: CGRect(x: 10, y: y + 20, width: 0, height: 0), colors: [UIColor.DarkGray, UIColor.clear])
            title.text = array[0] as? String
            title.font = Constant.setMediumFont(size: 17)
            title.sizeToFit()
            toView.addSubview(title)
            
            let value = UITextField()
            value.textFieldWithFrame(frame: CGRect(x: title.frame.origin.x, y: 0, width: toView.frame.width - 20, height: 30),
                                     font: Constant.setMediumFont(size: 17), colors: [UIColor.Blue, UIColor.clear], placeHolder: "")
            value.center.y = title.center.y
            value.text = "Все"
            value.textAlignment = .right
            
            toView.addSubview(value)
            let defaults = UserDefaults.standard
            switch i {
            case 0:
                mComplexType = value
               
                if defaults.bool(forKey: "afterBlackOut") == true
                {
                    self.addPicker(pickerView: pickerViewType, textField: mComplexType)
                    var names = ["Все"]
                    let array = CoreDataStack.sharedInstance.getComplexTypes()
                    
                    for i in 0..<array.count
                    {
                        let array = array[i] as? ComplexType
                        let name = array?.name ?? ""
                        names.append(name)
                        
                    }
                    mArray1 = names as NSArray
                }
                
                break
            case 1:
                mComplexClass = value
                if defaults.bool(forKey: "afterBlackOut") == true
                {
                    self.addPicker(pickerView: pickerViewClass, textField: mComplexClass)
                    var classNames = ["Все"]
                    let classArray = CoreDataStack.sharedInstance.getComplexClasses()
                    
                    for i in 0..<classArray.count
                    {
                        let array = classArray[i] as? ComplexClass
                        let name = array?.name ?? ""
                        classNames.append(name)
                    }
                    
                    mArray2 = classNames as NSArray
                }
                
                break
            default:
                break
            }
            y = value.frame.origin.y + value.frame.height
        }
        y += 20
        toView.contentSize = CGSize(width: toView.frame.width, height: y)
        
    }
    
    func addCreateReportViews()
    {
        mCreateReport = UIButton()
        mCreateReport.setButtonWithTitle(title: "Сформировать отчет", font: Constant.setMediumFont(size: 18), colors: [UIColor.White, UIColor.White.withAlphaComponent(0.3), UIColor.Blue])
        mCreateReport.frame = CGRect(x: 10, y: mScroll.contentSize.height, width: (mScroll.frame.width / 2) - 20, height: 50)
        mCreateReport.center.x = self.view.center.x
        mCreateReport.layer.cornerRadius = 5
        mCreateReport.addTarget(self, action: #selector(reportPressed), for: .touchUpInside)
        mScroll.addSubview(mCreateReport)
        
        mUpdateReport = UIButton()
        mUpdateReport.setButtonWithImage(image: "reload-icon", highlightedImage: "reload-icon")
        mUpdateReport.frame.size = CGSize(width: 50, height: 50)
        mUpdateReport.frame.origin.x = mScroll.frame.width - mUpdateReport.frame.width - 10
        mUpdateReport.center.y = mCreateReport.center.y
        mUpdateReport.alpha = 0
        mUpdateReport.layer.cornerRadius = mUpdateReport.frame.height / 2
        mUpdateReport.setBackgroundColor(.clear, for: .normal)
        mUpdateReport.setBackgroundColor(UIColor.BlueUltraAlpha, for: .highlighted)
        mUpdateReport.addTarget(self, action: #selector(createReport), for: .touchUpInside)
        mScroll.addSubview(mUpdateReport)
        
        mCreatingView = UIView()
        mCreatingView.frame = mCreateReport.frame
        mCreatingView.alpha = 0
        mScroll.addSubview(mCreatingView)
        
        let loading = UILabel()
        loading.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        loading.text = "Формирование отчета"
        loading.sizeToFit()
        loading.center.x = mCreatingView.frame.width / 2
        loading.frame.origin.y = mCreatingView.frame.height - loading.frame.height
        mCreatingView.addSubview(loading)
        
        let loadingIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            loadingIndicator.style = .medium
        } else {
            loadingIndicator.style = .white
        }
        loadingIndicator.color = .Blue
        loadingIndicator.center.x = loading.center.x
        loadingIndicator.frame.origin.y = loading.frame.origin.y - loadingIndicator.frame.height - 20
        loadingIndicator.startAnimating()
        mCreatingView.addSubview(loadingIndicator)
        
        mCreatingError = UILabel()
        mCreatingError.labelWithFrame(frame: CGRect(x: 5, y: mCreateReport.frame.origin.y + mCreateReport.frame.height + 10, width: mScroll.frame.width - 10, height: 15),
                                      colors: [UIColor.DarkGray, UIColor.clear])
        mCreatingError.font = Constant.setMediumFont(size: 14)
        mCreatingError.textAlignment = .center
        mCreatingError.alpha = 0
        mScroll.addSubview(mCreatingError)
        
        mScroll.contentSize = CGSize(width: mScroll.frame.width, height: mCreatingError.frame.origin.y + mCreatingError.frame.height + 20)
    }
    
    @objc func reportPressed(report: UIButton)
    {
        if report.titleLabel?.text == "Сформировать отчет"
        {
            self.createReport()
        }
        else
        {
            self.openReport()
        }
        self.view.endEditing(true)
    }
    
    @objc func dataBaseUpdated()
    {
        var names = ["Все"]
        let array = CoreDataStack.sharedInstance.getComplexTypes()
        
        for i in 0..<array.count
        {
            let array = array[i] as? ComplexType
            let name = array?.name ?? ""
            names.append(name)
            
        }
        mArray1 = names as NSArray
        
        
        self.addPicker(pickerView: pickerViewType, textField: mComplexType)
        mComplexType.isUserInteractionEnabled = true
        
        pickerViewType.tag = 20
        
        
        
        var classNames = ["Все"]
        let classArray = CoreDataStack.sharedInstance.getComplexClasses()
        
        for i in 0..<classArray.count
        {
            let array = classArray[i] as? ComplexClass
            let name = array?.name ?? ""
            classNames.append(name)
        }
        
        mArray2 = classNames as NSArray
        
        self.addPicker(pickerView: pickerViewClass, textField: mComplexClass)
        mComplexClass.isUserInteractionEnabled = true
        pickerViewClass.tag = 21
    }
    
    @objc func createReport()
    {
        if Connectivity.isConnectedToInternet()
        {
            mDelegate?.showReportCreatingMarker(reportType: .ReportTypeMain)
            UIView.animate(withDuration: 0.3) {
                self.mCreateReport.alpha = 0
                self.mUpdateReport.alpha = 0
                
                self.mCreatingView.alpha = 1
                self.mCreatingError.alpha = 0
            }
            
            let startDate = Date.dateFromString(dateString: mStartDate.text ?? "", pattern: "EEE, dd.MM.yyyy", enLocale: false)!
            let endDate = Date.dateFromString(dateString: mEndDate.text ?? "", pattern: "EEE, dd.MM.yyyy", enLocale: false)!
            
            let updateReportAlpha = mUpdateReport.alpha
            var timeChange:Bool!
            if mPeriod.text == "Не выбрано"
            {
                timeChange = false
            }
            else
            {
                timeChange = true
            }
            
            Networking.sharedInstance.LoadReportForStartDate(startDate: startDate,
                                                             endDate: endDate,
                                                             type: mComplexType.text ?? "",
                                                             cLass: mComplexClass.text ?? "", timeChange: timeChange) { (report) in
                self.mReport = report
                
                self.mCreateReport.frame.size.width = self.mScroll.frame.width / 2 - 20 - self.mUpdateReport.frame.width - 30
//                    self.mScroll.frame.width - self.mUpdateReport.frame.width - 30
                self.mCreateReport.setTitle("Открыть отчет", for: .normal)
                
                UIView.animate(withDuration: 0.3) {
                    self.mCreateReport.alpha = 1
                    self.mUpdateReport.alpha = 1
                    
                    self.mCreatingView.alpha = 0
                } completion: { (f: Bool) in
                    self.mDelegate?.showReportReadyMarker(reportType: .ReportTypeMain)
                }
            } failure:
            { (reason) in
                self.mDelegate?.showReportFailureMarker(reportType: .ReportTypeMain)
                self.mCreatingError.text = reason
                UIView.animate(withDuration: 0.3) {
                    self.mCreateReport.alpha = 1
                    self.mUpdateReport.alpha = updateReportAlpha
                    
                    self.mCreatingView.alpha = 0
                    self.mCreatingError.alpha = 1
                }
            }
        }
    }
    
    func openReport()
    {
        let reportController = ReportController(withReport: mReport)
        mDelegate?.pushViewController(controller: reportController)
    }
    func pickerView(picker: UIView, selectedPickerRow: Any?, atPosition: Int) {
        switch picker.tag {
        case 10:
            if selectedPickerRow != nil
            {
                mPeriod.text = selectedPickerRow as? String
                let interval = selectedPickerRow as? String == "День" ? Interval.DayInterval : (selectedPickerRow as? String == "Неделя" ? Interval.WeekInterval : Interval.MonthInterval)
                let nextDate = Date.dateFromDate(date: Date(), interval: interval)
                
                self.setDate(date: nextDate, textField: mStartDate)
                self.setDate(date: Date(), textField: mEndDate)
            }
            else
            {
                mPeriod.text = "Не выбрано"
            }
            
            break
        case 20:
            mComplexType.text = (selectedPickerRow == nil) ? "Все" : (selectedPickerRow as! NSDictionary).value(forKey: "name") as! String
            break
        case 21: mComplexClass.text = (selectedPickerRow == nil) ? "Все" : (selectedPickerRow as! NSDictionary).value(forKey: "name") as! String
            break
        default:
            break
        }
        self.showCreateReport()
    }
    
    func showCreateReport()
    {
        mCreateReport.frame.size.width = mScroll.frame.width / 2 - 20
        mCreateReport.setTitle("Сформировать отчет", for: .normal)
        
        mUpdateReport.alpha = 0
        
        mDelegate?.hideReportMarker(reportType: .ReportTypeMain)
    }
    
    func setDate(date: Date, textField: UITextField)
    {
        textField.text = Date.stringFromDate(date: date, pattern: "EEE, dd.MM.yyyy")
    }
    
    func pickerViewShouldClose()
    {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
