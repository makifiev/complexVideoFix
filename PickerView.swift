//
//  PickerView.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 14.11.2021.
//
//
//import Foundation
//import UIKit
//
//protocol PickerViewDelegate: class
//{
//    func pickerView(picker: UIView, selectedPickerRow: Any?, atPosition: Int)
//    func pickerView(picker: UIView, selectedDate: Date)
//    func pickerViewShouldClose()
//}

//class PickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource
//{
//
//
//    var mArray: NSArray = []
//    var mProperty: String = ""
//    var mToolBar: UIToolbar!
//    var mPicker: UIPickerView!
//    var mDatePicker: UIDatePicker!
//
//    weak var mPickerViewDelegate: PickerViewDelegate?
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    convenience init(withStrings: NSArray)
//    {
//        self.init(frame: CGRect.zero)
//        mArray = withStrings
//        self.addPicker()
//
//    }
//
//    override init(frame:CGRect)
//    {
//        super.init(frame: CGRect(x: 0, y: 0, width: Constant.mainFrame.size.width, height: Constant.iphone6 ? 246 : 216))
//        self.addToolBar()
//    }
//
//    convenience init(withObjects: NSArray, property: String)
//    {
//        self.init(frame: CGRect.zero)
//
//        mProperty = property
//        mArray = withObjects
//
////        self.addPicker()
//    }
//
//    convenience init(withDates frame: CGRect)
//    {
//        self.init(frame: CGRect.zero)
////        self.addDatePicker()
//    }
    
   
    
//    func addToolBar()
//    {
//        mToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: Constant.mainFrame.size.width, height: 30))
//        mToolBar.barStyle = .default
//        mToolBar.sizeToFit()
//
//        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//        let close = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeView))
//
//        mToolBar.setItems([space, close], animated: true)
//        self.addSubview(mToolBar)
//    }
//
//    func addPicker()
//    {
//        mPicker = UIPickerView()
//        mPicker.frame = CGRect(x: 0, y: mToolBar.frame.height, width: self.bounds.size.width, height: self.bounds.size.height - mToolBar.frame.height)
//        mPicker.showsLargeContentViewer = true
//        mPicker.delegate = self
////        mPicker.dataSource = self
//        self.addSubview(mPicker)
//
//        self.sendSubviewToBack(mPicker)
//    }
//
//    func addDatePicker()
//    {
//        let components = NSDateComponents()
//        components.year = NSCalendar.current.component(.year, from: Date()) - 1
//
//        mDatePicker = UIDatePicker()
//        mDatePicker.frame = CGRect(x: 0, y: mToolBar.frame.height, width: self.bounds.size.width, height: self.bounds.size.height - mToolBar.frame.height)
//        mDatePicker.datePickerMode = .date
//        mDatePicker.date = Date()
//        mDatePicker.minimumDate = NSCalendar.current.date(from: components as DateComponents)
//        mDatePicker.maximumDate = Date()
//
//        mDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
//        self.addSubview(mDatePicker)
//        self.sendSubviewToBack(mDatePicker)
//    }
//
//    func setDate(date: Date)
//    {
//        mDatePicker.date = date
//    }
//
//    @objc func closeView()
//    {
//        mPickerViewDelegate?.pickerViewShouldClose()
//    }
//
////    override func numberOfRows(inComponent component: Int) -> Int {
////
////    }
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return mArray.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return Constant.mainFrame.size.width
//    }
//
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 32
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let selectedObject = row == 0 ? nil : mArray[row - 1]
//        mPickerViewDelegate?.pickerView(picker: self, selectedPickerRow: selectedObject as Any, atPosition: row - 1)
//    }
////    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
////    {
////        var label = view as? UILabel
////        if label != nil
////        {
////            label = UILabel()
////            label!.labelWithFrame(frame: .zero, colors: [UIColor.black, UIColor.clear])
////            label!.font = Constant.setMediumFont(size: 22)
////            label!.textAlignment = .center
////        }
////        label?.text = mProperty.count != 0 ? ((row == 0) ? "Все" : ((mArray[row - 1]) as! NSDictionary).value(forKey: mProperty)) as! String : ((row == 0) ? nil : mArray[row - 1]) as! String
////        return label ?? UILabel()
////    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return  mProperty.count == 0 ? ((row == 0) ? "Все" : ((mArray[row - 1]) as! NSDictionary).value(forKey: mProperty)) as! String : ((row == 0) ? "" : mArray[row - 1]) as! String
////            mArray[row] as! String
//   }
//
//    @objc func datePickerValueChanged(datePicker: UIDatePicker)
//   {
//        mPickerViewDelegate?.pickerView(picker: self, selectedDate: datePicker.date)
//   }
//}

