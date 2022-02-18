//
//  Networking Singleton.swift
//  ККВФUITests
//
//  Created by Акифьев Максим  on 21.06.2021.
//

import Foundation
import Alamofire
import UIKit
import Kingfisher
import MRProgress

class Networking {
    
    
    static let sharedInstance = Networking()
    private init () {}
    
//    let url:String = "http://172.20.255.78:8282/cvfrest/mobile/"
//        let url:String = "http://172.20.255.186:8080/cvfrest/mobile/"
        let url = "https://cvfrest.stdpr.ru/cvfrest/mobile/"
    //    let url = "http://172.20.250.98:8383/cvfrest/mobile/"
    //    let url = "https://172.20.255.186:8443/cvfrest/mobile/"
//            let url = "http://172.20.255.186:8080/cvfrest/mobile/"
//    let url = "http://192.168.20.154:8282/cvfrest/mobile/"
//    let url = "http://10.177.0.111:8080/cvfrest/mobile/"
    
    var sessionToken:String = ""
    var day1:NSArray = []
    var day2:NSArray = []
     
    
    var manager: Session
    {
        let manager = AF  
        return manager
    }
     
    func OpenrequestPOSTURL(params : [String:AnyObject]?, completed: @escaping (Result<[[String: Any]]>) -> Void) {
        if Connectivity.isConnectedToInternet() {
            
            let currentURL = URL(string: url + "openSession")
            print(manager)
            
            
            manager.request(currentURL!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result
                {
                case.success( _):
                    
                    if let value = response.value as? [String : Any] {
                        if value.isEmpty == true {
                            print("Ошибка при запросе данных\(String(describing: response.error))")
                            completed(.nilResponse("Массив данных не получен"))
                            return
                        }
                        let arrayOfItems = [value]
                        for itm in arrayOfItems {
                            let item = authInfo(warning: itm["warning"] as? String,
                                                sessionID: itm["sessionID"] as? String,
                                                authCookieGen: itm["authorizationCookieGenerated"] as? Int,
                                                authCookie: itm["authorizationCookie"] as? String)
                            _ = item
                            
                            if let Token = itm["sessionID"] as? String
                            {
                                self.sessionToken = Token
                            }
                        }
                        
                        print(self.sessionToken)
                        completed(.Success(arrayOfItems))
                    }
                    
                case .failure( _):
                    if let error = response.error {
                        if ((error.errorDescription?.contains("The request timed out")) == true)
                        {
                            completed(.SessionTimeOut("Request timeout!"))
                        } else {
                            completed(.Error("Массив данных не получен"))
                            
                        }
                    }
                }
            }
        }
        else {
            completed(.LostConnection("Нет соединения"))
        }
    }
    
    func closeSession (params : [String : AnyObject]?, completed: @escaping (Result<NSArray>) -> Void) {
        if Connectivity.isConnectedToInternet() {
            let currentURL = URL(string: url + "closeSession/" + self.sessionToken )
            manager.request(currentURL!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result
                {
                case.success( _):
                    print("success")
                    completed(.Success([]))
                    
                case .failure( _):
                    if let error = response.error {
                        if ((error.errorDescription?.contains("The request timed out")) == true)
                        {
                            completed(.SessionTimeOut("Request timeout!"))
                        } else {
                            completed(.Error("Массив данных не получен"))
                            
                        }
                    }
                }
            }
        }
        else {
            completed(.LostConnection("Нет соединения"))
        }
    }
    
    func loadComplexesWithProgress(progress: MRCircularProgressView?, success:  @escaping () -> Void, failure: @escaping () -> Void)
    {
        if Connectivity.isConnectedToInternet() {
            let currentURL = URL(string: url + "allComplex/" + self.sessionToken )
            
            manager.request(currentURL!, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil, requestModifier: {$0.timeoutInterval = 1200}).responseJSON {
                response in
                
                switch response.result
                {
                case.success( _):
                    progress?.setProgress(0.3, animated: true)
                    
                    CoreDataStack.sharedInstance.processComplexes(complexes: response.value as! NSArray)
                    {
                        self.loadDummiesWithProgress(progress: progress, success: success, failure: failure)
                    }
                    failure:
                    {
                        failure()
                    }
                    
                    
                case .failure( _):
                     
                        if let error = response.error {
                            if ((error.errorDescription?.contains("The request timed out")) == true)
                            {
                                failure()
                            } else {
                                failure()
                                
                            }
                        }
                }
            }
            progress?.setProgress(0.1, animated: true)
        }
        else
        {
            failure()
        }
    }
    
    func loadDummiesWithProgress(progress: MRCircularProgressView?, success:  @escaping () -> Void, failure: @escaping () -> Void)
    {
        if Connectivity.isConnectedToInternet()
        {
            let currentURL = URL(string: url + "allMaket/" + self.sessionToken )
            manager.request(currentURL!, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result
                {
                case .success( _):
                    progress?.setProgress(0.6, animated: true)
                    CoreDataStack.sharedInstance.processDummies(dummies: response.value as! NSArray) {
                        self.loadDictsWithProgress(progress: progress, success: success, failure: failure)
                    } failure:
                    {
                        failure()
                    }
                    
                case .failure( _):
                    self.loadDictsWithProgress(progress: progress, success: success, failure: failure)
                        failure()
                }
            }
        }
        else
        {
            failure()
        }
    }
    
    func loadDictsWithProgress(progress: MRCircularProgressView?, success:  @escaping () -> Void, failure: @escaping () -> Void)
    {
        let dicts: NSArray = ["ComlpexClass", "ComlpexTypes", "DisableReasons", "Violation", "RefuseReason"]
        var loadDictsCount = 0
        for dict in dicts
        {
            let dict = dict as! String
            if Connectivity.isConnectedToInternet() {
                let currentURL = URL(string: url + "getDict/" + self.sessionToken + "/" + dict)
                manager.request(currentURL!, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil).responseJSON {
                    response in
                    switch response.result
                    {
                    case.success( _):
                        let step = (1 - Float(progress?.progress ?? 0)) / Float(dicts.count)
                        let checkCount =
                            {
                                
                                progress?.setProgress(progress?.progress ?? 0.0 + step, animated: true)
                                loadDictsCount += 1
                                if loadDictsCount == dicts.count
                                {
                                    CoreDataStack.sharedInstance.save(progress: progress ?? MRCircularProgressView(), success: success, failure: success)
                                }
                            }
                        if dict == "ComlpexClass"
                        {
                            CoreDataStack.sharedInstance.processComplexClasses(complexesClasses: response.value as! NSArray, success: checkCount, failure: failure)
                        }
                        else if dict == "ComlpexTypes"
                        {
                            CoreDataStack.sharedInstance.processComplexTypes(complexTypes: response.value as! NSArray, success: checkCount, failure: failure)
                        }
                        else if dict == "DisableReasons"
                        {
                            CoreDataStack.sharedInstance.processDisableReasons(disableReasons: response.value as! NSArray, success: checkCount, failure: failure)
                        }
                        else if dict == "Violation"
                        {
                            CoreDataStack.sharedInstance.processViolationTypes(violationTypes: response.value as! NSArray, success: checkCount, failure: failure)
                        }
                        else if dict == "RefuseReason"
                        {
                            CoreDataStack.sharedInstance.processRefuseReasons(refuseReasons: response.value as! NSArray, success: checkCount, failure: failure)
                        }
                        print(dict + "loaded")
                        
                    case .failure( _):
                            failure()
                    }
                }
            }
            else {
              
            }
            
            
        }
    }
    
    
    func loadCoddWorkReport(success: @escaping (CoddWorkReport) -> Void, failure:  @escaping (String) -> Void)
    {
        let date = Date()
        let dateFormat = "yyyy-MM-dd'T'HH:00:00.000'Z'"
        
        let dateBegin = Date.stringFromDate(date: Date.dateFromDate(date: date, day: -1, hour: 0), pattern: dateFormat)
        let dateEnd = Date.stringFromDate(date: Date.dateFromDate(date: date, day: 0, hour: -1), pattern: dateFormat)
        
        let parameters = ["dateBegin" : dateBegin,
                          "dateEnd": dateEnd]
        
        if Connectivity.isConnectedToInternet()
        {
            let currentURL = URL(string: url + "reportTsoddTsafap/" + self.sessionToken )
            manager.request(currentURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result
                {
                case .success( _):
                    
                    let items = response.value as AnyObject?
                    if items?.count != 0
                    {
                        let report = CoddWorkReport()
                        report.items = items
                        success(report)
                    }
                    else
                    {
                        let reason = "Ошибка формирования отчета!"
                        failure(reason)
                    }
                case .failure( _):
                    failure("Ошибка формирования отчета!")
                }
            }
        }
        
    }
    
    func LoadReportForStartDate(startDate: Date, endDate: Date, type: String, cLass: String,timeChange: Bool, success: @escaping (Report) -> Void, failure: @escaping (String) -> Void)
    {
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let startDateString = Date.stringFromDate(date: startDate, pattern: dateFormat)
        let endDateString = Date.stringFromDate(date: endDate, pattern: dateFormat)
        
        let interval = endDate.timeIntervalSince(startDate)
        let dateChange = interval / 86400
        let month = interval / 86400 >= 30
        
        let parameters = [:] as NSMutableDictionary
        parameters.setObject(startDateString, forKey: "dateBegin" as NSCopying)
        parameters.setObject(endDateString, forKey: "dateEnd" as NSCopying)
        
        if type != "Все"
        {
            let complexType = CoreDataStack.sharedInstance.getComplexType(name: type)
            parameters.setObject(complexType?.id ?? 0, forKey: "typeId" as NSCopying)
        }
        
        if cLass != "Все"
        {
            let complexClass = CoreDataStack.sharedInstance.getComplexClass(name: cLass)
            parameters.setObject(complexClass?.id ?? 0, forKey: "classId" as NSCopying)
        }
        
        var reportLoaded = false
        var refuseReportLoaded = false
        let report: Report = Report()
        if Connectivity.isConnectedToInternet()
        {
            let currentURL = URL(string: url + "reportCVF/" + self.sessionToken )
            
            manager.request(currentURL!, method: .post, parameters: parameters as? Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result
                {
                case .success( _):
                    CoreDataStack.sharedInstance.processReport(report: report,
                                                               info: response.value as! NSDictionary, reportProcess: month ? ReportProcess.ReportProcessAll : ReportProcess.ReportProcessList) { (report) in
                        reportLoaded = true
                        if reportLoaded && refuseReportLoaded
                        {
                            success(report)
                        }
                    } failure: {
                        failure("Ошибка формирования отчета!")
                    }
                    
                case .failure( _):
                    
                    failure("Ошибка формирования отчета!")
                    
                }
            }
            print(parameters)
            let currentUrl2 = URL(string: url + "reportCVFRefuse/" + self.sessionToken )
            manager.request(currentUrl2!, method: .post, parameters: parameters as? Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result
                {
                case .success( _):
                    CoreDataStack.sharedInstance.processReport(report: report,
                                                               info: response.value as! NSDictionary, reportProcess: ReportProcess.ReportProcessAll) { (report) in
                        refuseReportLoaded = true
                        if reportLoaded && refuseReportLoaded
                        {
                            success(report)
                        }
                    } failure: {
                        failure("Ошибка формирования отчета!")
                    }
                    
                case .failure( _):
                    failure("Ошибка формирования отчета!")
                }
            }
            
            if !timeChange && dateChange == 0
            {
                let startDate = Date.dateFromDate(date: endDate, interval: .MonthInterval)
                let startDateString = Date.stringFromDate(date: startDate, pattern: dateFormat)
                
                parameters.setObject(startDateString, forKey: "dateBegin" as NSCopying)
                
                let currentUrl2 = URL(string: url + "reportCVF/" + self.sessionToken )
                manager.request(currentUrl2!, method: .post, parameters: parameters as? Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
                    response in
                    switch response.result
                    {
                    case .success( _):
                        CoreDataStack.sharedInstance.processReport(report: report,
                                                                   info: response.value as! NSDictionary, reportProcess: ReportProcess.ReportProcessHistory) { (report) in
                            NotificationCenter.default.post(name: NSNotification.Name(Constant.historyReady),
                                                            object: nil,
                                                            userInfo: ["success" : true])
                        } failure:
                        {
                            NotificationCenter.default.post(name: NSNotification.Name(Constant.historyReady),
                                                            object: nil,
                                                            userInfo: ["success" : false])
                        }
                        
                    case .failure( _):
                        //                            failure("Ошибка формирования отчета!")
                        NotificationCenter.default.post(name: NSNotification.Name(Constant.historyReady),
                                                        object: nil,
                                                        userInfo: ["success" : false])
                    }
                }
                
                let currentUrl3 = URL(string: url + "reportCVFRefuse/" + self.sessionToken )
                manager.request(currentUrl3!, method: .post, parameters: parameters as? Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
                    response in
                    switch response.result
                    {
                    case .success( _):
                        CoreDataStack.sharedInstance.processReport(report: report,
                                                                   info: response.value as! NSDictionary, reportProcess: ReportProcess.ReportProcessAll) { (report) in
                            refuseReportLoaded = true
                            if reportLoaded && refuseReportLoaded
                            {
                                success(report)
                            }
                        } failure: {
                            failure("Ошибка формирования отчета!")
                        }
                        
                    case .failure( _):
                        failure("Ошибка формирования отчета!")
                    }
                }
            }
        }
    }
       
    func loadTransitPhoto(transit : Int, success: @escaping(UIImage?) -> Void, failure: @escaping(String) -> Void) {
        if Connectivity.isConnectedToInternet() {
             
            let currentURL =
                //                URL(string: "https://vgtk.ru/uploads/posts/2017-01/1484326456_1.jpg")
                URL(string: url + "photoCheck/" + self.sessionToken + "/" + String(transit))
            //            downloadImage(from: currentURL!, imageView: imageView)
           
            AF.request(currentURL!, method: .get).response
            { response in

               switch response.result {
                case .success(let responseData):
                    if responseData != nil
                    {
                    let photo = UIImage(data: responseData!, scale:1)
                    success(photo!)
                    }
                    else
                    {
//                        success(nil)
                        failure("Нет данных")
                    }
                case .failure(let error):
                    print("error--->",error)
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL, imageView: UIImageView) {
        print("Download Started")
        
    }
    
    func loadTransitsForCamera(params : [String:AnyObject]?, camera : Int, completed: @escaping (Result<NSArray>) -> Void) {
        if Connectivity.isConnectedToInternet() {
            let currentURL = URL(string:"\(url)lastCameraCheck/\(self.sessionToken)/\(camera)/10")
            manager.request(currentURL!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result
                {
                case.success( _):
                    let value = response.value as? NSArray

                    completed(.Success(value ?? []))

                case .failure( _):
                    if let error = response.error {
                        if ((error.errorDescription?.contains("The request timed out")) == true)
                        {
                            completed(.SessionTimeOut("Request timeout!"))
                        } else {
                            completed(.Error("Массив данных не получен"))
                            
                        }
                    }
                }
            }
        }
        else {
            completed(.LostConnection("Нет соединения"))
        }
    }
    func loadComplexStatusReport(success: @escaping (ComplexStatusReport) -> Void, failure: @escaping (String) -> Void)
    {
        let date = Date()
        let dateFormat = "yyyy-MM-dd'T'HH:00:00.000'Z'"
        
        let fromDate1 = Date.stringFromDate(date: Date.dateFromDate(date: date, day: -1, hour: 0), pattern: dateFormat)
        let toDate1 = Date.stringFromDate(date: Date.dateFromDate(date: date, day: 0, hour: -1), pattern: dateFormat)
        let fromDate2 = Date.stringFromDate(date: Date.dateFromDate(date: date, day: -2, hour: 0), pattern: dateFormat)
        let toDate2 = Date.stringFromDate(date: Date.dateFromDate(date: date, day: -1, hour: -1), pattern: dateFormat)
        
        let parameters = ["fromDate1": fromDate1,
                          "toDate1": toDate1,
                          "fromDate2": fromDate2,
                          "toDate2": toDate2]
        
        if Connectivity.isConnectedToInternet()
        {
            let currentURL = URL(string: url + "reportWorkClass/" + self.sessionToken)
            manager.request(currentURL!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result
                {
                case .success(_):
                    let days = response.value as? NSArray ?? []
                    if days.count > 1
                    {
                        let sortByName = NSSortDescriptor(key: "name", ascending: true)
                        
                        let report = ComplexStatusReport()
                        
                        report.day1 = [(days[0] as! NSArray).sortedArray(using: [sortByName])]
                        report.day2 = [(days[1] as! NSArray).sortedArray(using: [sortByName])]
                        
                        report.format {
                            success(report)
                        } failure: { (reason) in
                            failure(reason)
                        }
                        
                    }
                    else
                    {
                        let reason = "Ошибка формирования отчета!"
                        failure(reason)
                    }
                    
                case .failure(_):
                    let reason = "Ошибка формирования отчета!"
                    failure(reason)
                }
            }
        }
        else
        {
            failure("Нет сети")
        }
    } 
        
    func loadDisabledComplexReport(success: @escaping (DisabledComplexReport) -> Void, failure: @escaping(String) -> Void)
    {
        if Connectivity.isConnectedToInternet()
        {
            let currentURL = URL(string: url + "reportUnworkResons/" + self.sessionToken)
            manager.request(currentURL!, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil, requestModifier: {$0.timeoutInterval = 1800}).responseJSON {
                response in
                switch response.result
                {
                case.success( _):
                    
                    let days = response.value as! NSDictionary
                    if days.allKeys.count > 1
                    {
                        let format = "EEE MMM dd HH:mm:ss 'MSK' yyyy"
                        let day1 = Date.dateFromString(dateString: days.allKeys[0] as! String, pattern: format, enLocale: true)
                        let day2 = Date.dateFromString(dateString: days.allKeys[1] as! String, pattern: format, enLocale: true)
                        
                        let report = DisabledComplexReport()
                        if (day1!.compare(day2!)) == ComparisonResult.orderedAscending
                        {
                            report.day1 = days[days.allKeys[1]] as! [NSDictionary]
                            report.day2 = days[days.allKeys[0]] as! [NSDictionary]
                        }
                        else
                        {
                            report.day1 = days[days.allKeys[0]] as! [NSDictionary]
                            report.day2 = days[days.allKeys[1]] as! [NSDictionary]
                        }
                         
                            success(report)
                    }
                    else
                    {
                        let reason = "Ошибка формирования отчета!"
                            failure(reason)
                    }
                    
                case .failure( _):
                    let reason = "Ошибка формирования отчета!"
                        failure(reason)
                    
                }
            }
        }
        else
        {
            let reason = "Нет сети"
                failure(reason)
            
        }
        
    }
    
}

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

enum Result<T> {
    case Success(T)
    case Error(String)
    case SessionTimeOut(String)
    case LostConnection(String)
    case NetworkError(String)
    case nilResponse(String)
}
enum resultImage
{
    case Success(UIImage)
    case Error(String)
}

