//
//  coreDataStack.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 06.07.2021.
//

import Foundation
import CoreData
import UIKit
import MRProgress

class CoreDataStack: NSObject {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static let sharedInstance = CoreDataStack()
    private override init() {}
    
    
    var mComplex = [] as NSMutableArray
    var mCameras = [] as NSMutableArray
    var mViolations = [] as NSMutableArray
    var mDummies = [] as NSMutableArray
    var mComlexClasses = [] as NSMutableArray
    var mComplexType = [] as NSMutableArray
    var mDisableReasons = [] as NSMutableArray
    var mViolationTypes = [] as NSMutableArray
    var mRefuseReasons = [] as NSMutableArray
    
    var zero: Int = 0
    var one: Int = 0
    var two: Int = 0
    var three: Int = 0
    
    
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let fileURL = URL(string: "Model.sqlite", relativeTo: dirURL)
        do {
            try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType,
                                                configurationName: nil,
                                                at: fileURL, options: nil)
        } catch {
            fatalError("Error configuring persistent store: \(error)")
        }
        return coordinator
    }()
    
    lazy var mMainContext: NSManagedObjectContext = {
        if Constant.iOS11IsAvailable()
        {
            var mMainContext1 = persistentContainer.viewContext
            mMainContext1.automaticallyMergesChangesFromParent = true
            return mMainContext1
        }
        else
        {
            var mMainContext1 = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            mMainContext1.persistentStoreCoordinator = persistentStoreCoordinator
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(contextDidSaveMainContext),
                name: UIDevice.batteryLevelDidChangeNotification,
                object: mMainContext1)
            
            return mMainContext1
        }
    }()
    
    lazy var mPrivateContext: NSManagedObjectContext =
        {
            if Constant.iOS11IsAvailable()
            {
                var mPrivateContext = persistentContainer.newBackgroundContext()
                mPrivateContext.automaticallyMergesChangesFromParent = true
                return mPrivateContext
            }
            else
            {
                var  mPrivateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                mPrivateContext.persistentStoreCoordinator = persistentStoreCoordinator
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(contextDidSavePrivateContext),
                    name: UIDevice.batteryLevelDidChangeNotification,
                    object: mPrivateContext)
                return mPrivateContext
            }
        }()
    
    var  m_violations: NSMutableArray = []
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd") else
        {
            fatalError("Failed to find data model")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        
        let container = NSPersistentContainer(name: "Model")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    @objc func contextDidSaveMainContext(notification: NSNotification)
    {
        let serialQueue = DispatchQueue(label: "DidSaveMainContext.Queue")
        serialQueue.sync {
            // code
            mMainContext.perform {
                self.mMainContext.mergeChanges(fromContextDidSave: notification as Notification)
            }
        }
    }
    @objc func contextDidSavePrivateContext(notification: NSNotification)
    {
        let serialQueue = DispatchQueue(label: "DidSavePrivateContext.Queue")
        serialQueue.sync {
            // code
            mPrivateContext.perform {
                self.mPrivateContext.mergeChanges(fromContextDidSave: notification as Notification)
            }
        }
    }
    
    // MARK: - Core Data Saving support
    
    
    func saveContext (completion: (_ success: Bool) -> Void) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completion(true)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequestComplex = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Complex.self))
            let fetchRequestCamera = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Camera.self))
            let fetchRequestViolationType = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ViolationType.self))
            let fetchRequestRefuseReason = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: RefuseReason.self))
            let fetchRequestDisableReason = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: DisableReason.self))
            let fetchRequestComplexType = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ComplexType.self))
            let fetchRequestComplexClass = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ComplexClass.self))
            let fetchRequestDummy = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Dummy.self))
            let fetchRequestViolation = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Violation.self))
            
            do {
                let objectsComplex = try context.fetch(fetchRequestComplex) as? [NSManagedObject]
                let objectsCamera = try context.fetch(fetchRequestCamera) as? [NSManagedObject]
                let objectsViolationType = try context.fetch(fetchRequestViolationType) as? [NSManagedObject]
                let objectsRefuseReason = try context.fetch(fetchRequestRefuseReason) as? [NSManagedObject]
                let objectsDisableReason = try context.fetch(fetchRequestDisableReason) as? [NSManagedObject]
                let objectsComplexType = try context.fetch(fetchRequestComplexType) as? [NSManagedObject]
                let objectsComplexClass = try context.fetch(fetchRequestComplexClass) as? [NSManagedObject]
                let objectsDummy = try context.fetch(fetchRequestDummy) as? [NSManagedObject]
                let objectsViolations = try context.fetch(fetchRequestViolation) as? [NSManagedObject]
                
                _ = objectsComplex.map{$0.map{context.delete($0)}}
                _ = objectsCamera.map{$0.map{context.delete($0)}}
                _ = objectsViolationType.map{$0.map{context.delete($0)}}
                _ = objectsRefuseReason.map{$0.map{context.delete($0)}}
                _ = objectsDisableReason.map{$0.map{context.delete($0)}}
                _ = objectsComplexType.map{$0.map{context.delete($0)}}
                _ = objectsComplexClass.map{$0.map{context.delete($0)}}
                _ = objectsDummy.map{$0.map{context.delete($0)}}
                _ = objectsViolations.map{$0.map{context.delete($0)}}
                
                DispatchQueue.main.async {
                    CoreDataStack.sharedInstance.saveContext
                    {
                        (success) -> Void in
                    }
                }
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
            
        }
    }
    func saveComplexes(complexes: NSArray)
    {
        for i in 0..<complexes.count
        {
            let dictionary = complexes[i] as! NSDictionary

            let complex = self.getNewObjectInEntity(entity: Complex.self) as? Complex
            complex?.clId = dictionary["classId"] as? Int64 ?? 0
            complex?.clName = dictionary["className"] as? String
            complex?.id = dictionary["id"] as? Int64 ?? 0
            complex?.model = dictionary["model"] as? String
            complex?.name = dictionary["name"] as? String
            complex?.serfiffEndDate = dictionary["sertifEndDate"] as? String
            complex?.state = dictionary["state"] as? Int64 ?? 0
            complex?.stateName = dictionary["stateName"] as? String
            complex?.typeId = dictionary["typeId"] as? Int64 ?? 0
            complex?.typeName = dictionary["typeName"] as? String
            if complex?.state != 5
            {
                var unworkReasons: String = ""
                let date = Date.dateFromString(dateString: complex?.serfiffEndDate ?? "", pattern: "yyyy-MM-dd", enLocale: false)
                if date == nil || date?.compare(Date()) == ComparisonResult.orderedAscending
                {
                    unworkReasons = "Нет действующего сертификата поверки"
                }
                else if Date.dateFromDate(date: date!, interval: Interval.MonthInterval).compare(Date()) == ComparisonResult.orderedAscending
                {
                    unworkReasons = "Истекает время сертификата поверки (менее 30 дней)"
                }
                
                let cameras = dictionary["cameras"] as! NSArray
                let extra = extraDict(addCameras: cameras,
                                      complex: complex?.id ?? 0,
                                      cLass: complex?.clName ?? "",
                                      type: complex?.typeName ?? "",
                                      complexUnworkReasons: unworkReasons)
                
                complex?.lat = extra["lat"] as? Double ?? 0.0
                complex?.lng = extra["lng"] as? Double ?? 0.0
                complex?.placeName = extra["placeName"] as? String
                complex?.summaryEfficiency = extra["summaryEfficiency"] as? String
                complex?.summaryPassages = extra["summaryPassages"] as? String
                complex?.summaryViolations = extra["summaryViolations"] as? String
                complex?.summaryResolutions = extra["summaryResolutions"] as? String
                complex?.workState = extra["workState"] as! Int64
                
                complex?.workerDays = extra["workerDays"] as? Int64 ?? 0
                
                let state = String(complex?.workState ?? 0)
                let workTitle = "\(Constant.workTitle[state] ?? "") \(String(complex?.workerDays ?? 0)) дней"
                complex?.workTitle = workTitle
                complex?.unworkReasons = extra["unworkReasons"] as? String
                mComplex.add(complex)
                
            }
        }
        
    }
    
    func extraDict(addCameras: NSArray?, complex: Int64, cLass: String, type: String, complexUnworkReasons: String) -> NSDictionary
    {
        let extra:NSMutableDictionary = [:]
        var coordinates = false
        var placeName = false
        var workstate = Constant.any
        let states:NSMutableDictionary = [:]
        
        var complexEfficiency = 0
        var complexEfficiencyAll = 0
        var complexPassages = 0
        var complexPassagesAll = 0
        var complexViolations = 0
        var complexViolationsAll = 0
        var complexResolutions = 0
        var complexResolutionsAll = 0
        
        for i in stride(from: 0, to: addCameras?.count ?? 0, by: 1)
        {
            let addCameras = addCameras?[i] as! NSDictionary

            let camera = self.getNewObjectInEntity(entity: Camera.self) as! Camera
            camera.azimuth = addCameras["azimuth"] as? Int64 ?? 0
            camera.clName = cLass
            camera.complexId = complex
            camera.directionId = addCameras["directionId"] as? Int64 ?? 0
            camera.directionName = addCameras["directionName"] as? String
            camera.externalId = addCameras["externalId"] as? String
            camera.id = addCameras["id"] as? Int64 ?? 0
            camera.lat = addCameras["lat"] as? Double ?? 0.0
            camera.lng = addCameras["lng"] as? Double ?? 0.0
            camera.name = addCameras["name"] as? String
            camera.placeName = addCameras["placeName"] as? String
            camera.purposeTypeName = addCameras["purposeTypeName"] as? String
            camera.stateId = addCameras["stateId"] as? Int64 ?? 0
            camera.stateName = addCameras["stateName"] as? String
            camera.tsafap = addCameras["tsafap"] as? Int64 ?? 0
            camera.typeName = type
            camera.workFlag = addCameras["workFlag"] as? Int64 ?? 0
            camera.workerDays = addCameras["workerDays"] as? Int64 ?? 0
            camera.workerId = addCameras["workerId"] as? Int64 ?? 0
            camera.workerName = addCameras["workerName"] as? String
            
            var unworkReasons = ""
            
            if (!coordinates && camera.lat != nil && camera.lng != nil)
            {
                coordinates = true
                extra.setObject(camera.lat ?? 0.0, forKey: "lat" as NSCopying)
                extra.setObject(camera.lng ?? 0.0, forKey: "lng" as NSCopying)
            }
            if (!placeName && camera.placeName != nil)
            {
                placeName = true
                extra.setObject(camera.placeName ?? "", forKey: "placeName" as NSCopying)
            }
            
            camera.workState = Int64(camera.workFlag == Constant.work ? Constant.work : Constant.noWork)
            if camera.stateId == Constant.archive
            {
                unworkReasons.append("В архиве")
                camera.workState = Int64(camera.workFlag == Constant.work ? Constant.workLimited : Constant.noWorkWithReason)
            }
            else if complexUnworkReasons.count != 0
            {
                unworkReasons.append(complexUnworkReasons)
                if camera.workFlag == Constant.work
                {
                    camera.workState = Int64(Constant.workLimited)
                }
            }
            if camera.tsafap == 0
            {
                if camera.workerId != 0
                {
                    if unworkReasons.count  != 0
                    {
                        unworkReasons.append("\n")
                    }
                    unworkReasons.append("Исключено из обработки ЦАФАП")
                    camera.workState = Int64(camera.workFlag == Constant.work ? Constant.workLimited : Constant.noWorkWithReason)
                }
            }
            else
            {
                if unworkReasons.count != 0
                {
                    unworkReasons.append("\n")
                }
                unworkReasons.append("Не обрабатывается ЦАФАП")
                if camera.workFlag == Constant.work
                {
                    camera.workState = Int64(Constant.workLimited)
                }
            }
            
            camera.workTitle = "\(Constant.workTitle[String(camera.workState)] ?? "") \(camera.workerDays) дней"
            
            states.setObject(camera.workerDays , forKey: camera.workState as NSCopying)
            
            camera.unworkReasons = unworkReasons
            extra.setObject(camera.unworkReasons ?? "", forKey: "unworkReasons" as NSCopying)
            
            if camera.stateId == Constant.archive
            {
                if camera.workState == Constant.work || camera.workState == Constant.workLimited
                {
                    workstate = Constant.workLimited
                }
            }
            else
            {
                if workstate == Constant.any
                {
                    workstate = Int(camera.workState)
                }
                else if (workstate == Constant.work) && !(camera.workState == Constant.work)
                {
                    workstate = Constant.workLimited
                }
                else if workstate == Constant.noWork && !(camera.workState == Constant.noWorkWithReason)
                {
                    workstate = Constant.noWorkWithReason
                }
            }
            
            let summaryEfficiency = addCameras["summaryFrom1"] as? Int64 ?? 0
            let summaryEfficiencyAll = addCameras["summaryOn1"] as? Int64 ?? 0
            let summaryPassages = addCameras["summaryFrom2"] as? Int64 ?? 0
            let summaryPassagesAll = addCameras["summaryOn2"] as? Int64 ?? 0
            let summaryViolations = addCameras["summaryFrom3"] as? Int64 ?? 0
            let summaryViolationsAll = addCameras["summaryOn3"] as? Int64 ?? 0
            let summaryResolutions = addCameras["summaryFrom4"] as? Int64 ?? 0
            let summaryResolutionsAll = addCameras["summaryOn4"] as? Int64 ?? 0
            
            camera.summaryEfficiency = "\(summaryEfficiency)/\(summaryEfficiencyAll)"
            camera.summaryPassages = "\(summaryPassages)/\(summaryPassagesAll)"
            camera.summaryViolations = "\(summaryViolations)/\(summaryViolationsAll)"
            camera.summaryResolutions = "\(summaryResolutions)/\(summaryResolutionsAll)"
            
            complexEfficiency += Int(summaryEfficiency)
            complexEfficiencyAll += Int(summaryEfficiencyAll)
            complexPassages += Int(summaryPassages)
            complexPassagesAll += Int(summaryPassagesAll)
            complexViolations += Int(summaryViolations)
            complexViolationsAll += Int(summaryViolationsAll)
            complexResolutions += Int(summaryResolutions)
            complexResolutionsAll += Int(summaryResolutionsAll)
            
            let violations = addCameras["viols"] as! NSArray
            
            addViolations(violations: violations, camera: camera.id, complex: complex)
            mCameras.add(camera)
        }
        
        var workerDays = workstate == Constant.noWork ? 100000 : 0
        for i in stride(from: 0, to: states.allKeys.count, by: 1)
        {
            if workstate == Constant.work
            {
                workerDays = max(workerDays, states[states.allKeys[i]] as! Int)
            }
            else if workstate == Constant.noWorkWithReason && states.allKeys[i] as! Int == Constant.noWorkWithReason
            {
                workerDays = max(workerDays, states[states.allKeys[i]] as! Int)
            }
            else if workstate == Constant.noWork
            {
                workerDays = min(workerDays, states[states.allKeys[i]] as! Int)
            }
            else if workstate == Constant.workLimited
            {
                workerDays = max(workerDays, states[states.allKeys[i]] as! Int)
            }
        }
        extra.setObject(workerDays , forKey: "workerDays" as NSCopying)
        extra.setObject(workstate , forKey: "workState" as NSCopying)
        
        if addCameras?.count != 0
        {
            complexEfficiency /= addCameras!.count
            complexEfficiencyAll /= addCameras!.count
            
            extra.setObject("\(complexEfficiency)\(complexEfficiencyAll)", forKey: "summaryEfficiency" as NSCopying)
            extra.setObject("\(complexPassages)\(complexPassagesAll)", forKey: "summaryPassages" as NSCopying)
            extra.setObject("\(complexViolations)\(complexViolationsAll)", forKey: "summaryViolations" as NSCopying)
            extra.setObject("\(complexResolutions)\(complexResolutionsAll)", forKey: "summaryResolutions" as NSCopying)
        }
        return extra
    }
    func addViolations(violations:NSArray?, camera: Int64, complex: Int64)
    {
        for itm in stride(from: 0, to: violations?.count ?? 0, by: 1)
        {
            let dict = violations?[itm] as! NSDictionary

            let violation = self.getNewObjectInEntity(entity: Violation.self) as! Violation
            violation.cameraId = camera;
            violation.complexId = complex;
            violation.directionId = dict["directionId"] as? Int64 ?? 0
            violation.directionName = dict["directionName"] as? String ?? ""
            violation.id = dict["id"]as? Int64 ?? 0
            violation.limitStr = dict["limitStr"] as? String ?? ""
            violation.parentId = dict["parentId"] as? String ?? ""
            violation.state = dict["state"] as? Int64 ?? 0
            violation.stateName =  dict["stateName"] as? String ?? ""
            violation.statePriority = dict["statePriority"]as? String ?? ""
            violation.violExcessLevel = dict["violExcessLevel"] as? Int64 ?? 0
            violation.violId = dict["violId"] as? Int64 ?? 0
            violation.violLimitId = dict["violLimitId"] as? Int64 ?? 0
            violation.violName = dict["violName"] as? String ?? ""
            violation.violValueLimit = dict["violValueLimit"] as? Int64 ?? 0
            violation.violValueUnit = dict["violValueUnit"] as? String ?? ""
            violation.zoneId = dict["zoneId"] as? Int64 ?? 0
            violation.zoneName = dict["zoneName"] as? String ?? ""
            mViolations.add(violation)
        }
    }
    func addDummies(dummies: NSArray)
    {
        for i in 0..<dummies.count
        {
            let dict = dummies[i] as! NSDictionary

            let dummy = self.getNewObjectInEntity(entity: Dummy.self) as! Dummy
            if (dict["stateId"] as? Int64 ?? 0 != Constant.archive)
            {
                dummy.azimuth = dict["azimuth"] as? Int64 ?? 0
                dummy.clId = dict["classId"] as? Int64 ?? 0
                dummy.clName = dict["className"] as? String ?? ""
                dummy.id = dict["id"] as? Int64 ?? 0
                dummy.inventoryNumber = dict["inventory"] as? String ?? ""
                dummy.lat = dict["lat"] as? Double ?? 0.0
                dummy.lng = dict["lng"] as? Double ?? 0.0
                dummy.name = dict["name"] as? String ?? ""
                dummy.note = dict["note"] as? String ?? ""
                dummy.placeName = dict["placeName"] as? String ?? ""
                dummy.serialNumber =  dict["serialNo"] as? String ?? ""
                dummy.stateId =  dict["stateId"]  as? Int64 ?? 0
                dummy.stateName =  dict["stateName"] as? String ?? ""
                dummy.typeId =  dict["typeId"]  as? Int64 ?? 0
                dummy.typeName =  dict["typeName"] as? String ?? ""
                
                if dummy.stateId != Constant.archive
                {
                    mDummies.add(dummy)
                }
            }
        }
    }
    func addComplexClasses(classes: NSArray)
    {
        for i in 0..<classes.count
        {
            let dict = classes[i] as! NSDictionary

            let complexClass = self.getNewObjectInEntity(entity: ComplexClass.self) as! ComplexClass
            complexClass.id = dict["ID"] as? Int64 ?? 0
            complexClass.name = dict["NAME"] as? String ?? ""
            
            mComlexClasses.add(complexClass)
        }
    }
    
    func addComplexTypes(types: NSArray)
    {
        for i in 0..<types.count
        {
            let dict = types[i] as! NSDictionary

            let complexType = self.getNewObjectInEntity(entity: ComplexType.self) as! ComplexType
            complexType.acronym = dict["ACRONYM"] as? String ?? ""
            complexType.id = dict["ID"] as? Int64 ?? 0
            complexType.mobilityType = dict["MOBILITY_TYPE"] as? Int64 ?? 0
            complexType.name = dict["NAME"] as? String ?? ""
            
            mComplexType.add(complexType)
        }
    }
    
    func addDisableReasons(reasons: NSArray)
    {
        for i in 0..<reasons.count
        {
            let dict = reasons[i] as! NSDictionary

            let disableReason = self.getNewObjectInEntity(entity: DisableReason.self) as! DisableReason
            disableReason.id = dict["ID"] as? Int64 ?? 0
            disableReason.name = dict["NAME"] as? String ?? ""
            
            mDisableReasons.add(disableReason)
        }
    }
    
    func addViolationTypes(types: NSArray)
    {
        for i in 0..<types.count
        {
            let dict = types[i] as! NSDictionary

            let violationType = self.getNewObjectInEntity(entity: ViolationType.self) as! ViolationType
            violationType.id = dict["ID"] as? Int64 ?? 0
            violationType.name = dict["VIOL_NAME"] as? String ?? ""
            violationType.type = dict["TIP_NAME"] as? String ?? ""
            
            mViolationTypes.add(violationType)
            
        }
    }
    
    func addRefuseReasons(reasons: NSArray)
    {
        for i in 0..<reasons.count
        {
            let dict = reasons[i] as! NSDictionary

            let refuseReason = self.getNewObjectInEntity(entity: RefuseReason.self) as! RefuseReason
            refuseReason.id = dict["REASON_ID"] as? Int64 ?? 0
            refuseReason.reason = dict["REASON"] as? String ?? ""
            
            mRefuseReasons.add(refuseReason)
            
        }
    }
    
    var optionalVal: String?
    lazy var liftUuidPredicate: NSPredicate? = {guard let liftUuid = optionalVal else { return nil }
        return NSPredicate(format: "id = %@", liftUuid)
    }()
    
    func getComplexClassNames() -> NSArray
    {
        
        let complexes: NSFetchedResultsController = fetchedResultsControllerForEntity(entity: Complex.self,
                                                                                      predicate: liftUuidPredicate,
                                                                                      section: "clName",
                                                                                      sortKeys: ["clName"],
                                                                                      ascendings: [true])
        let names: NSMutableArray = []
        for sectionInfo:NSFetchedResultsSectionInfo in complexes.sections ?? []
        {
            names.add(sectionInfo.name)
        }
        return names
    }
    func fetchedResultsControllerForEntity(entity: AnyClass,predicate: NSPredicate?, section: String?, sortKeys: NSArray, ascendings: NSArray) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let FRC: NSFetchedResultsController<NSFetchRequestResult> = {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(entity))
            let context = getCurrentContext()
            let entityDescription = NSEntityDescription.entity(forEntityName: NSStringFromClass(entity), in: context)
            fetchRequest.entity = entityDescription
            var sortDescriptors = [NSSortDescriptor]()
            for item in stride(from: 0, to: sortKeys.count, by: 1)
            {
                let sortDescriptor = NSSortDescriptor(key: sortKeys[item] as? String, ascending: ascendings[item] as! Bool)
                sortDescriptors.append(sortDescriptor)
            }
            
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicate
            
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: section, cacheName: nil)
            
            
            do {
                try fetchedResultsController.performFetch()
            } catch let error  {
                print("ERROR: \(error)")
            }
            return fetchedResultsController
        }()
        return FRC
        
    }
    func getComplexesAndDummiesByLatitude(lat: Double, lng: Double) -> NSArray
    {
        let minLat = lat - Constant.latitudeAccuracyCoefficient
        let maxLat = lat + Constant.latitudeAccuracyCoefficient
        let minLng = lng - Constant.longitudeAccuracyCoefficient
        let maxLng = lng + Constant.longitudeAccuracyCoefficient
        
        let complexesAndDummies: NSMutableArray = []
        let predicate = NSPredicate(format: "(lat >= %f AND lat <= %f) AND (lng >= %f AND lng <= %f)", minLat, maxLat, minLng, maxLng)
        let complexes = self.fetchedResultsControllerForEntity(entity: Complex.self,
                                                               predicate: predicate,
                                                               section: nil,
                                                               sortKeys: ["name"],
                                                               ascendings: [true])
        complexesAndDummies.addObjects(from: complexes.fetchedObjects ?? [])
        
        let dummies = self.fetchedResultsControllerForEntity(entity: Dummy.self,
                                                             predicate: predicate,
                                                             section: nil,
                                                             sortKeys: ["name"],
                                                             ascendings: [true])
        complexesAndDummies.addObjects(from: dummies.fetchedObjects ?? [])
        return complexesAndDummies
        
    }
    
    func getComplexesByNameOrAddress(nameOrAddress: String) -> NSFetchedResultsController<NSFetchRequestResult>!
    {
        let predicate = NSPredicate(format: "name contains[cd] %@ OR placeName contains[cd] %@", nameOrAddress, nameOrAddress)
        let fetchResController: NSFetchedResultsController<NSFetchRequestResult> = self.fetchedResultsControllerForEntity(entity: Complex.self,
                                                                                                                          predicate: predicate,
                                                                                                                          section: nil,
                                                                                                                          sortKeys: ["name"],
                                                                                                                          ascendings: [true])
        return fetchResController
    }
    
    func getComplexWorkStates() -> NSArray
    {
        let complexes = (self.fetchedResultsControllerForEntity(entity: Complex.self,
                                                                predicate: nil,
                                                                section: nil,
                                                                sortKeys: ["name"],
                                                                ascendings: [true]))
        let workStates: NSMutableArray = []
        for i in 0..<complexes.fetchedObjects!.count
        {
            let complex = complexes.fetchedObjects?[i] as! Complex
            workStates.add(complex.workState)
        }
        return workStates
        
    }
    func getComplexesByNameOrAddressInIds(nameOrAddress: String, inIds: NSArray?) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let predicates: NSMutableArray = []
        if inIds != nil
        {
            predicates.add(NSPredicate(format: "id IN %@", [inIds!]))
            if nameOrAddress.count != 0
            {
                predicates.add(NSPredicate(format: "name contains[cd] %@ OR placeName contains[cd] %@", [nameOrAddress, nameOrAddress]))
            }
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates as! [NSPredicate])
        
        return self.fetchedResultsControllerForEntity(entity: Complex.self,
                                                      predicate: predicate,
                                                      section: nil,
                                                      sortKeys: ["name"],
                                                      ascendings: [true])
    }
    
    func getComplexesByNameOrAddressInIdsForDisable(nameOrAddress: String, byCameras: NSArray?) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let predicates: NSMutableArray = []
        if byCameras != nil
        {
            //            predicates.add(NSPredicate(format: "id IN %@", [byCameras!]))
            let predicate = NSPredicate(format: "( id IN %@ )", byCameras!)
            let cameras = self.fetchedResultsControllerForEntity(entity: Camera.self,
                                                                 predicate: predicate,
                                                                 section: "complexId",
                                                                 sortKeys: ["complexId"],
                                                                 ascendings: [true])
            
            let complexIds: NSMutableArray = []
            for sectionInfo in cameras.sections!
            {
                complexIds.add(sectionInfo.name)
            }
            predicates.add(NSPredicate(format: "( id IN %@ )", complexIds))
            
            if nameOrAddress.count != 0
            {
                predicates.add(NSPredicate(format: "( name contains[cd] %@ OR placeName contains[cd] %@ )", nameOrAddress, nameOrAddress))
                
            }
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates as! [NSPredicate])
        
        return self.fetchedResultsControllerForEntity(entity: Complex.self,
                                                      predicate: predicate,
                                                      section: nil,
                                                      sortKeys: ["name"],
                                                      ascendings: [true])
    }
    
    
    func getCamerasInComplex(complex: Int) -> NSArray
    {
        let complexId = Int64(complex)
        let predicate = NSPredicate(format: "(complexId == %i)", complexId)
        let returnArray = (self.fetchedResultsControllerForEntity(entity: Camera.self,
                                                                  predicate: predicate,
                                                                  section: nil,
                                                                  sortKeys: ["name", "id"],
                                                                  ascendings: [true, true])).fetchedObjects! as NSArray
        return returnArray
    }
    
    func getCamerasSortedByTypeAndClassInIds(ids: NSArray) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let predicate = NSPredicate(format: "id IN %@", ids)
        let returnArray = (self.fetchedResultsControllerForEntity(entity: Camera.self,
                                                                  predicate: predicate,
                                                                  section: "typeName",
                                                                  sortKeys: ["typeName", "clName"],
                                                                  ascendings: [false, true]))
        return returnArray
    }
    
    func getCameraInComplex(complex: Int) -> Camera?
    {
        let returnCamera = (self.getCamerasInComplex(complex: complex))
        
        if returnCamera.count == 0
        {
            return nil
            
        }
        else
        {
            let returnCamera1 = (self.getCamerasInComplex(complex: complex))[0]
            return returnCamera1 as? Camera
        }
        
    }
    
    func getComplexesByNameOrAddress(nameOrAddress: String, ids: NSArray) -> NSFetchedResultsController<NSFetchRequestResult>
    
    {
        let predicates: NSMutableArray = []
        if ids != nil
        {
            predicates.add(NSPredicate(format: "id IN %@", ids))
            if nameOrAddress.count != 0
            {
                predicates.add(NSPredicate(format: "name contains[cd] %@ OR placeName contains[cd] %@", nameOrAddress, nameOrAddress))
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates as! [NSPredicate])
        let returnObject = self.fetchedResultsControllerForEntity(entity: Complex.self,
                                                                  predicate: predicate,
                                                                  section: nil,
                                                                  sortKeys: ["name"],
                                                                  ascendings: [true])
        return returnObject
    }
    
    func getComplexType(name: String) -> ComplexType?
    {
        let predicate = NSPredicate(format: "name == %@", name)
        
        let controller = self.fetchedResultsControllerForEntity(entity: ComplexType.self,
                                                                predicate: predicate,
                                                                section: nil,
                                                                sortKeys: ["name"],
                                                                ascendings: [true])
        return (controller.fetchedObjects?.count != 0) ? controller.fetchedObjects?[0] as? ComplexType : nil
    }
    
    func getComplexClass(name: String) -> ComplexClass?
    {
        let predicate = NSPredicate(format: "name == %@", name)
        
        let controller = self.fetchedResultsControllerForEntity(entity: ComplexClass.self,
                                                                predicate: predicate,
                                                                section: nil,
                                                                sortKeys: ["name"],
                                                                ascendings: [true])
        return (controller.fetchedObjects?.count != 0) ? controller.fetchedObjects?[0] as? ComplexClass : nil
    }
    
    func getViolationType(id: Int) -> ViolationType?
    {
        let predicate = NSPredicate(format: "id == %i", id)
        
        let controller = self.fetchedResultsControllerForEntity(entity: ViolationType.self,
                                                                predicate: predicate,
                                                                section: nil,
                                                                sortKeys: ["id"],
                                                                ascendings: [true])
        return (controller.fetchedObjects?.count != 0) ? controller.fetchedObjects?[0] as? ViolationType : nil
    }
    
    func getRefuseReason(id: Int) -> RefuseReason?
    {
        let predicate = NSPredicate(format: "id == %i", id)
        let controller = self.fetchedResultsControllerForEntity(entity: RefuseReason.self,
                                                                predicate: predicate,
                                                                section: nil,
                                                                sortKeys: ["id"],
                                                                ascendings: [true])
        let returnElement = controller.fetchedObjects?.count
        return returnElement != nil ? controller.fetchedObjects![0] as? RefuseReason : nil
    }
    
    func getComplexTypes() -> NSArray
    {
        let returnArray = (self.fetchedResultsControllerForEntity(entity: ComplexType.self,
                                                                  predicate: nil,
                                                                  section: nil,
                                                                  sortKeys: ["name"],
                                                                  ascendings: [true])).fetchedObjects! as NSArray
        return returnArray
    }
    
    func getComplexClasses() -> NSArray
    {
        let returnArray = (self.fetchedResultsControllerForEntity(entity: ComplexClass.self,
                                                                  predicate: nil,
                                                                  section: nil,
                                                                  sortKeys: ["name"],
                                                                  ascendings: [true])).fetchedObjects! as NSArray
        return returnArray
    }
    
    func getDisableReasons() -> NSArray
    {
        let returnArray = (self.fetchedResultsControllerForEntity(entity: DisableReason.self,
                                                                  predicate: nil,
                                                                  section: nil,
                                                                  sortKeys: ["id"],
                                                                  ascendings: [true])).fetchedObjects! as NSArray
        return returnArray
    }
    
    
    func getComplexes(filters: NSArray?) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let predicates: NSMutableArray = []
        if filters != nil
        {
            if (filters![0] as! Int) > -1
            {
                predicates.add(NSPredicate(format: "workState == %@", filters![0] as! CVarArg))
            }
            if (filters![1] as! String) != ""
            {
                predicates.add(NSPredicate(format: "clName == %@", filters![1] as! CVarArg))
            }
        }
        predicates.add(NSPredicate(format: "lat != %@", 0))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates as! [NSPredicate])
        return self.fetchedResultsControllerForEntity(entity: Complex.self,
                                                      predicate: predicate,
                                                      section: nil,
                                                      sortKeys: ["id"],
                                                      ascendings: [true])
    }
    func getDummies(filters: NSArray?) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let predicates: NSMutableArray = []
        if filters != nil
        {
            if !(filters![1] as! String == "")
            {
                predicates.add(NSPredicate(format: "clName == %@", filters![1] as! CVarArg))
            }
        }
        predicates.add(NSPredicate(format: "lat != %@", 0))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates as! [NSPredicate])
        return self.fetchedResultsControllerForEntity(entity: Dummy.self,
                                                      predicate: predicate,
                                                      section: nil,
                                                      sortKeys: ["id"],
                                                      ascendings: [true])
    }
    
    func getViolations(id: Int) -> Violation?
    {
        let predicate = NSPredicate(format: "id == %i", id)
        let controller = (self.fetchedResultsControllerForEntity(entity: Violation.self,
                                                                 predicate: predicate,
                                                                 section: nil,
                                                                 sortKeys: ["violId"],
                                                                 ascendings: [true]))
        let returnelement = controller.fetchedObjects?.count
        return returnelement != nil ? controller.fetchedObjects![0] as? Violation : nil
    }
    
    func getViolationsForComplex(complex: Int) -> NSArray
    {
        let complexId = Int64(complex)
        let predicate = NSPredicate(format: "(complexId == %i)", complexId)
        let returnArray = (self.fetchedResultsControllerForEntity(entity: Violation.self,
                                                                  predicate: predicate,
                                                                  section: nil,
                                                                  sortKeys: ["id"],
                                                                  ascendings: [true])).fetchedObjects! as NSArray
        return returnArray
    }
    
    func getViolationsForCamera(camera: Int) -> NSArray
    {
        let cameraId = Int64(camera)
        let predicate = NSPredicate(format: "(cameraId == %i)", cameraId)
        let returnArray = (self.fetchedResultsControllerForEntity(entity: Violation.self,
                                                                  predicate: predicate,
                                                                  section: nil,
                                                                  sortKeys: ["id"],
                                                                  ascendings: [true])).fetchedObjects! as NSArray
        return returnArray
    }
    
    func getCurrentContext() -> NSManagedObjectContext
    {
        return Thread.isMainThread ? mMainContext : mPrivateContext
    }
    
    func processComplexes(complexes: NSArray, success: @escaping () -> Void, failure: @escaping () -> Void)
    {
        do {
            try ObjC.catchException
            {
                DispatchQueue.global(qos: .background).async
                { [self] in
                    let _ = saveComplexes(complexes: complexes)
                    DispatchQueue.main.async {
                        if success != nil
                        {
                            success()
                        }
                    }
                }
            }
        }
        catch {
            if failure != nil
            {
                failure()
            }
            print("An error ocurred: \(error)")
        }
    }
    
    func processDummies(dummies: NSArray, success: @escaping () -> Void, failure: @escaping () -> Void)
    {
        do {
            try ObjC.catchException
            {
                DispatchQueue.global(qos: .background).async
                { [self] in
                    let _ = addDummies(dummies: dummies)
                    DispatchQueue.main.async {
                        if success != nil
                        {
                            success()
                        }
                    }
                }
            }
        }
        catch {
            if failure != nil
            {
                failure()
            }
            print("An error ocurred: \(error)")
        }
    }
    
    
    func processComplexClasses(complexesClasses: NSArray, success: @escaping () -> Void, failure: @escaping () -> Void)
    {
        do {
            try ObjC.catchException
            {
                DispatchQueue.global(qos: .background).async
                { [self] in
                    let _ = addComplexClasses(classes: complexesClasses)
                    DispatchQueue.main.async {
                        if success != nil
                        {
                            success()
                        }
                    }
                }
            }
        }
        catch {
            if failure != nil
            {
                failure()
            }
            print("An error ocurred: \(error)")
        }
    }
    
    func processComplexTypes(complexTypes: NSArray, success: @escaping () -> Void, failure: @escaping () -> Void)
    {
        do {
            try ObjC.catchException
            {
                DispatchQueue.global(qos: .background).async
                { [self] in
                    let _ = addComplexTypes(types: complexTypes)
                    DispatchQueue.main.async {
                        if success != nil
                        {
                            success()
                        }
                    }
                }
            }
        }
        catch {
            if failure != nil
            {
                failure()
            }
            print("An error ocurred: \(error)")
        }
    }
    
    func processDisableReasons(disableReasons: NSArray, success: @escaping () -> Void, failure: @escaping () -> Void)
    {
        do {
            try ObjC.catchException
            {
                DispatchQueue.global(qos: .background).async
                { [self] in
                    let _ = addDisableReasons(reasons: disableReasons)
                    DispatchQueue.main.async {
                        if success != nil
                        {
                            success()
                        }
                    }
                }
            }
        }
        catch {
            if failure != nil
            {
                failure()
            }
            print("An error ocurred: \(error)")
        }
    }
    
    func processViolationTypes(violationTypes: NSArray, success: @escaping () -> Void, failure: @escaping () -> Void)
    {
        do {
            try ObjC.catchException
            {
                DispatchQueue.global(qos: .background).async
                { [self] in
                    addViolationTypes(types: violationTypes)
                    DispatchQueue.main.async {
                        if success != nil
                        {
                            success()
                        }
                    }
                }
            }
        }
        catch {
            if failure != nil
            {
                failure()
            }
            print("An error ocurred: \(error)")
        }
    }
    
    func processRefuseReasons(refuseReasons: NSArray, success: @escaping () -> Void, failure: @escaping () -> Void)
    {
        do {
            try ObjC.catchException
            {
                DispatchQueue.global(qos: .background).async
                { [self] in
                    let _ = addRefuseReasons(reasons: refuseReasons)
                    DispatchQueue.main.async {
                        if success != nil
                        {
                            success()
                        }
                    }
                }
            }
        }
        catch {
            if failure != nil
            {
                failure()
            }
            print("An error ocurred: \(error)")
        }
    }
    
    func processReport(report: Report, info: NSDictionary, reportProcess: ReportProcess, success: @escaping (Report) -> Void, failure: @escaping () -> Void)
    {
        do
        {
            try tryProcessReport(report: report, info: info, reportProcess: reportProcess, success: success, failure: failure)
        }
        catch
        {
            if failure != nil
            {
                failure()
            }
        }
    }
    
    func tryProcessReport(report: Report, info: NSDictionary, reportProcess: ReportProcess, success: @escaping (Report) -> Void, failure: @escaping () -> Void) throws
    {
        for key in info.allKeys as! [NSString]
        {
            if reportProcess != ReportProcess.ReportProcessAll
            {
                
                if reportProcess == ReportProcess.ReportProcessHistory && !key.contains("history")
                {
                    continue
                }
                if reportProcess == ReportProcess.ReportProcessList && key.contains("history")
                {
                    continue
                }
            }
            
            
            self.insertInreport(report: report, info: info)
            
        }
        if success != nil
        {
            success(report)
        }
    }
    
    
    func save(progress:MRCircularProgressView, success: @escaping () -> Void, failure: @escaping () -> Void)
    {
        do {
            try ObjC.catchException({
                [self] in
                clearEntity(entity: Complex.self, predicate: nil)
                for complex in mComplex
                {
                    saveObject(object: complex as! Complex)
                }
                
                clearEntity(entity: Camera.self, predicate: nil)
                for camera in mCameras
                {
                    saveObject(object: camera as! Camera)
                }
                
                clearEntity(entity: Violation.self, predicate: nil)
                for violation in mViolations
                {
                    saveObject(object: violation as! Violation)
                }
                
                clearEntity(entity: Dummy.self, predicate: nil)
                for dummy in mDummies
                {
                    self.saveObject(object: dummy as! Dummy)
                }
                
                clearEntity(entity: ComplexClass.self, predicate: nil)
                for complexClass in mComlexClasses
                {
                    saveObject(object: complexClass as! ComplexClass)
                }
                
                clearEntity(entity: ComplexType.self, predicate: nil)
                for complexType in mComplexType
                {
                    saveObject(object: complexType as! ComplexType)
                }
                
                clearEntity(entity: DisableReason.self, predicate: nil)
                for disableReason in mDisableReasons
                {
                    self.saveObject(object: disableReason as! DisableReason)
                }
                
                clearEntity(entity: ViolationType.self, predicate: nil)
                for violationType in mViolationTypes
                {
                    self.saveObject(object: violationType as! ViolationType)
                }
                
                clearEntity(entity: RefuseReason.self, predicate: nil)
                for refuseReason in mRefuseReasons
                {
                    self.saveObject(object: refuseReason as! RefuseReason)
                }
                
                self.saveContextSelf()
                
                mComplex.removeAllObjects()
                mCameras.removeAllObjects()
                mViolations.removeAllObjects()
                
                mDummies.removeAllObjects()
                
                mComlexClasses.removeAllObjects()
                mComplexType.removeAllObjects()
                mDisableReasons.removeAllObjects()
                mViolationTypes.removeAllObjects()
                mRefuseReasons.removeAllObjects()
                DispatchQueue.main.async {
                    progress.setProgress(1, animated: false)
                    if success != nil
                    {
                        success()
                    }
                }
            })
        } catch {
            if failure != nil
            {
                failure()
            }
        }
    }
    
    
    
    func clearEntity(entity: AnyClass, predicate: NSPredicate?)
    {
        let controller: NSFetchedResultsController<NSFetchRequestResult> =
            self.fetchedResultsControllerForEntity(entity: entity,
                                                   predicate: predicate,
                                                   section: nil,
                                                   sortKeys: [],
                                                   ascendings: [])
        self.clearController(controller: controller)
    }
    func clearController(controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        let objectsToDelete = controller.fetchedObjects! as NSArray
        for i in 0..<objectsToDelete.count
        {
            let object = objectsToDelete[i] as! NSManagedObject
            self.deleteObject(object: object)
        }
    }
    
    func deleteObject(object: NSManagedObject)
    {
        let context = self.getCurrentContext() as NSManagedObjectContext
        context.delete(object)
    }
    
    func saveObject(object: NSManagedObject)
    {
        let context = self.getCurrentContext() as NSManagedObjectContext
        context.insert(object)
    }
    func saveContextSelf()
    {
        let context = self.getCurrentContext()
        do {
            try context.save()
        } catch _
        {
            print("error")
        }
    }
    
    func getNewObjectInEntity(entity:AnyClass) -> NSManagedObject
    {
        let entityDesc = NSEntityDescription.entity(forEntityName: NSStringFromClass(entity.self), in: self.getCurrentContext())!
        let object = NSManagedObject.init(entity: entityDesc, insertInto: nil)
        return object
    }
    
}

extension CoreDataStack {
    
    func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
    
    
    
    func insertInreport(report: Report, info: NSDictionary)
    {
        report.cvfListMeasure_1 = info["cvfListMeasure_1"]  as? NSArray ?? []
        
        report.cvfListMeasure_10 = info["cvfListMeasure_10"] as? NSArray ?? []
        report.cvfListMeasure_11 = info["cvfListMeasure_11"] as? NSDictionary ?? [:]
        report.cvfListMeasure_11_xx = info["cvfListMeasure_11_xx"] as? NSDictionary ?? [:]
        report.cvfListMeasure_2 = info["cvfListMeasure_2"] as? NSDictionary ?? [:]
        report.cvfListMeasure_3 = info["cvfListMeasure_3"]as? NSArray ?? []
        report.cvfListMeasure_3_1 = info["cvfListMeasure_3_1"] as? NSArray ?? []
        report.cvfListMeasure_3_2 = info["cvfListMeasure_3_2"] as? NSArray ?? []
        report.cvfListMeasure_4 = info["cvfListMeasure_4"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5 = info["cvfListMeasure_5"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_1 = info["cvfListMeasure_5_1"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2 = info["cvfListMeasure_5_2"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2_1 = info["cvfListMeasure_5_2_1"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2_1_1 = info["cvfListMeasure_5_2_1_1"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2_1_2 = info["cvfListMeasure_5_2_1_2"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2_1_3 = info["cvfListMeasure_5_2_1_3"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2_2 = info["cvfListMeasure_5_2_2"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2_2_1 = info["cvfListMeasure_5_2_2_1"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2_2_2 = info["cvfListMeasure_5_2_2_2"] as? NSDictionary ?? [:]
        report.cvfListMeasure_5_2_2_3 = info["cvfListMeasure_5_2_2_3"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6 = info["cvfListMeasure_6"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_1_1 = info["cvfListMeasure_6_1_1"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_1_2 = info["cvfListMeasure_6_1_2"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_1_3 = info["cvfListMeasure_6_1_3"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_2_1 = info["cvfListMeasure_6_2_1"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_2_2 = info["cvfListMeasure_6_2_2"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_2_3 = info["cvfListMeasure_6_2_3"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_3_1 = info["cvfListMeasure_6_3_1"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_3_2 = info["cvfListMeasure_6_3_2"] as? NSDictionary ?? [:]
        report.cvfListMeasure_6_3_3 = info["cvfListMeasure_6_3_3"] as? NSDictionary ?? [:]
        report.cvfListMeasure_7 = info["cvfListMeasure_7"] as? NSDictionary ?? [:]
        report.cvfListMeasure_8 = info["cvfListMeasure_8"] as? NSArray ?? []
        report.cvfListMeasure_8_1 = info["cvfListMeasure_8_1"] as? NSArray ?? []
        report.cvfListMeasure_8_2 = info["cvfListMeasure_8_2"] as? NSArray ?? []
        report.cvfListMeasure_9 = info["cvfListMeasure_9"] as? NSArray ?? []
        report.historyDates = info["historyDates"] as? NSArray ?? []
        report.historyMeasure_1 = info["historyMeasure_1"] as? NSDictionary ?? [:]
        report.historyMeasure_10 = info["historyMeasure_10"] as? NSDictionary ?? [:]
        report.historyMeasure_11 = info["historyMeasure_11"] as? NSDictionary ?? [:]
        report.historyMeasure_11_xx = info["historyMeasure_11_xx"] as? NSDictionary ?? [:]
        report.historyMeasure_2 = info["historyMeasure_2"] as? NSDictionary ?? [:]
        report.historyMeasure_3 = info["historyMeasure_3"] as? NSDictionary ?? [:]
        report.historyMeasure_3_1 = info["historyMeasure_3_1"] as? NSDictionary ?? [:]
        report.historyMeasure_3_2 = info["historyMeasure_3_2"] as? NSDictionary ?? [:]
        report.historyMeasure_4 = info["historyMeasure_4"] as? NSDictionary ?? [:]
        report.historyMeasure_5 = info["historyMeasure_5"] as? NSDictionary ?? [:]
        report.historyMeasure_5_1 = info["historyMeasure_5_1"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2 = info["historyMeasure_5_2"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2_1 = info["historyMeasure_5_2_1"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2_1_1 = info["historyMeasure_5_2_1_1"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2_1_2 = info["historyMeasure_5_2_1_2"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2_1_3 = info["historyMeasure_5_2_1_3"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2_2 = info["historyMeasure_5_2_2"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2_2_1 = info["historyMeasure_5_2_2_1"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2_2_2 = info["historyMeasure_5_2_2_2"] as? NSDictionary ?? [:]
        report.historyMeasure_5_2_2_3 = info["historyMeasure_5_2_2_3"] as? NSDictionary ?? [:]
        report.historyMeasure_6 = info["historyMeasure_6"] as? NSDictionary ?? [:]
        report.historyMeasure_6_1_1 = info["historyMeasure_6_1_1"] as? NSDictionary ?? [:]
        report.historyMeasure_6_1_2 = info["historyMeasure_6_1_2"] as? NSDictionary ?? [:]
        report.historyMeasure_6_1_3 = info["historyMeasure_6_1_3"] as? NSDictionary ?? [:]
        report.historyMeasure_6_2_1 = info["historyMeasure_6_2_1"] as? NSDictionary ?? [:]
        report.historyMeasure_6_2_2 = info["historyMeasure_6_2_2"] as? NSDictionary ?? [:]
        report.historyMeasure_6_2_3 = info["historyMeasure_6_2_3"] as? NSDictionary ?? [:]
        report.historyMeasure_6_3_1 = info["historyMeasure_6_3_1"] as? NSDictionary ?? [:]
        report.historyMeasure_6_3_2 = info["historyMeasure_6_3_2"] as? NSDictionary ?? [:]
        report.historyMeasure_6_3_3 = info["historyMeasure_6_3_3"] as? NSDictionary ?? [:]
        report.historyMeasure_7 = info["historyMeasure_7"] as? NSDictionary ?? [:]
        report.historyMeasure_8 = info["historyMeasure_8"] as? NSDictionary ?? [:]
        report.historyMeasure_8_1 = info["historyMeasure_8_1"] as? NSDictionary ?? [:]
        report.historyMeasure_8_2 = info["historyMeasure_8_2"] as? NSDictionary ?? [:]
        report.historyMeasure_9 = info["historyMeasure_9"] as? NSDictionary ?? [:]
        
        report.measure_1 = info["measure_1"] as? NSNumber ?? 0
        report.measure_10 = info["measure_10"] as? NSNumber ?? 0
        report.measure_11 = info["measure_11"] as? NSNumber ?? 0
        report.measure_11_xx = info["measure_11_xx"] as? NSDictionary ?? [:]
        report.measure_2 = info["measure_2"] as? NSNumber ?? 0
        report.measure_3 = info["measure_3"] as? NSNumber ?? 0
        report.measure_3_1 = info["measure_3_1"] as? NSNumber ?? 0
        report.measure_3_2 = info["measure_3_2"] as? NSNumber ?? 0
        report.measure_4 = info["measure_4"] as? NSNumber ?? 0
        report.measure_5 = info["measure_5"] as? NSNumber ?? 0
        report.measure_5_1 = info["measure_5_1"] as? NSNumber ?? 0
        report.measure_5_2 = info["measure_5_2"] as? NSNumber ?? 0
        report.measure_5_2_1 = info["measure_5_2_1"] as? NSNumber ?? 0
        report.measure_5_2_1_1 = info["measure_5_2_1_1"] as? NSNumber ?? 0
        report.measure_5_2_1_2 = info["measure_5_2_1_2"] as? NSNumber ?? 0
        report.measure_5_2_1_3 = info["measure_5_2_1_3"] as? NSNumber ?? 0
        report.measure_5_2_2 = info["measure_5_2_2"] as? NSNumber ?? 0
        report.measure_5_2_2_1 = info["measure_5_2_2_1"]as? NSNumber ?? 0
        report.measure_5_2_2_2 = info["measure_5_2_2_2"] as? NSNumber ?? 0
        report.measure_5_2_2_3 = info["measure_5_2_2_3"] as? NSNumber ?? 0
        report.measure_6 = info["measure_6"] as? NSNumber ?? 0
        report.measure_6_1_1 = info["measure_6_1_1"] as? NSNumber ?? 0
        report.measure_6_1_2 = info["measure_6_1_2"] as? NSNumber ?? 0
        report.measure_6_1_3 = info["measure_6_1_3"] as? NSNumber ?? 0
        report.measure_6_2_1 = info["measure_6_2_1"] as? NSNumber ?? 0
        report.measure_6_2_2 = info["measure_6_2_2"] as? NSNumber ?? 0
        report.measure_6_2_3 = info["measure_6_2_3"] as? NSNumber ?? 0
        report.measure_6_3_1 = info["measure_6_3_1"] as? NSNumber ?? 0
        report.measure_6_3_2 = info["measure_6_3_2"] as? NSNumber ?? 0
        report.measure_6_3_3 = info["measure_6_3_3"] as? NSNumber ?? 0
        report.measure_7 = info["measure_7"] as? NSNumber ?? 0
        report.measure_8 = info["measure_8"] as? NSNumber ?? 0
        report.measure_8_1 = info["measure_8_1"] as? NSNumber ?? 0
        report.measure_8_2 = info["measure_8_2"] as? NSNumber ?? 0
        report.measure_9 = info["measure_9"] as? NSNumber ?? 0
        if info["violListMeasure_5"] != nil
        {
            report.violListMeasure_5 = info["violListMeasure_5"] as? NSDictionary ?? [:]
            report.violListMeasure_5_1 = info["violListMeasure_5_1"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2 = info["violListMeasure_5_2"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2_1 = info["violListMeasure_5_2_1"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2_1_1 = info["violListMeasure_5_2_1_1"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2_1_2 = info["violListMeasure_5_2_1_2"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2_1_3 = info["violListMeasure_5_2_1_3"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2_2 = info["violListMeasure_5_2_2"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2_2_1 = info["violListMeasure_5_2_2_1"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2_2_2 = info["violListMeasure_5_2_2_2"] as? NSDictionary ?? [:]
            report.violListMeasure_5_2_2_3 = info["violListMeasure_5_2_2_3"] as? NSDictionary ?? [:]
            report.violListMeasure_6 = info["violListMeasure_6"] as? NSDictionary ?? [:]
            report.violListMeasure_6_1_1 = info["violListMeasure_6_1_1"] as? NSDictionary ?? [:]
            report.violListMeasure_6_1_2 = info["violListMeasure_6_1_2"] as? NSDictionary ?? [:]
            report.violListMeasure_6_1_3 = info["violListMeasure_6_1_3"] as? NSDictionary ?? [:]
            report.violListMeasure_6_2_1 = info["violListMeasure_6_2_1"] as? NSDictionary ?? [:]
            report.violListMeasure_6_2_2 = info["violListMeasure_6_2_2"] as? NSDictionary ?? [:]
            report.violListMeasure_6_2_3 = info["violListMeasure_6_2_3"] as? NSDictionary ?? [:]
            report.violListMeasure_6_3_1 = info["violListMeasure_6_3_1"] as? NSDictionary ?? [:]
            report.violListMeasure_6_3_2 = info["violListMeasure_6_3_2"] as? NSDictionary ?? [:]
            report.violListMeasure_6_3_3 = info["violListMeasure_6_3_3"] as? NSDictionary ?? [:]
            report.violListMeasure_7 = info["violListMeasure_7"] as? NSDictionary ?? [:]
            report.refuseListMeasure_5_2_2 = info["refuseListMeasure_5_2_2"] as? NSDictionary ?? [:]
            report.refuseListMeasure_5_2_2_1 = info["refuseListMeasure_5_2_2_1"] as? NSDictionary ?? [:]
            report.refuseListMeasure_5_2_2_2 = info["refuseListMeasure_5_2_2_2"] as? NSDictionary ?? [:]
            report.refuseListMeasure_5_2_2_3 = info["refuseListMeasure_5_2_2_3"] as? NSDictionary ?? [:]
            report.refuseListMeasure_6_1_3 = info["refuseListMeasure_6_1_3"] as? NSDictionary ?? [:]
            report.refuseListMeasure_6_2_3 = info["refuseListMeasure_6_2_3"] as? NSDictionary ?? [:]
            report.refuseListMeasure_6_3_3 = info["refuseListMeasure_6_3_3"] as? NSDictionary ?? [:]
            report.refuseListMeasure_7 = info["refuseListMeasure_7"] as? NSDictionary ?? [:]
        }
    }
}
