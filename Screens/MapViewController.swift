//
//  MapViewController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.06.2021.
//

import Foundation
import UIKit
import GoogleMaps
import GoogleMapsUtils


protocol MapControllerDelegate: class
{
    func pushViewController(controlelr: UIViewController)
    func hideSearchPanel()
    func showSearchPanel()
    func showCopyAlertlabel(text: String)
}

class MapViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate, GMUClusterRendererDelegate, SearchControllerDelegate, TableViewDelegate, CLLocationManagerDelegate, ComplexControllerDelegate, DummyControllerDelegate
{
    
    

//    @IBOutlet var mapViewTopConstraint: NSLayoutConstraint!
    var locationManager: CLLocationManager!
    var mUserLocation: CLLocation! = nil
    var mComplexMarker: UIView!
    var mCameraMarker: UIImageView!
    var mMarkersIcons: NSMutableDictionary! = [:]
    var mComlexClusterManager: GMUClusterManager!
    var mDummyClustermanager: GMUClusterManager!
    var mMultieComplexTable: TableView!
    var mSelectedCompleName: String!
    var mSelectedMiltipleComlexesAndDummies: NSArray!
    var mFilters:NSArray!
     
    var mapView: GMSMapView!
    
    weak var mDelegate: MapControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMultipleComplexTable()
        setupMap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.dataBaseUpdated), name: Notification.Name(Constant.dataBaseUpdated), object: nil)
    
        self.hideMultipleComplexTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
//        UIApplication.shared.statusBarUIView?.isHidden = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.dataBaseUpdated), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

      }
    
    func setupMap()
    {
//        self.view.frame.size.height *= 1.5
        let defaults = UserDefaults.standard
        let mapType = defaults.integer(forKey: Constant.mapType)
        
        let camera: GMSCameraPosition = .camera(withTarget: Constant.moscowCoordiantes, zoom: 9)
//        let height = self.view.frame.height * 1.5
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), camera: camera)
        mapView.frame.size.height *= 1.4
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: self.view.frame.height / 2, right: 0)
        mapView.mapType = mapType == 1 ? GMSMapViewType.hybrid : GMSMapViewType.normal
        mapView.settings.consumesGesturesInView = false
         
//        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)
//        mapView.frame.size.height = mapView.frame.size.height * 1.5
        print(mapView.frame)
        print(self.view.frame)
        mapView.camera = camera
        
        let google = mapView.subviews[1]
        google.isHidden = true
        
        self.addMarkers()
        self.addDummies()
        self.enableMyLocation()
        
    }
    
    func addComplexMarkerWithColor(color: UIColor)
    {
        mComplexMarker = UIView.init()
        mComplexMarker.frame.size = CGSize(width: 10, height: 10)
        mComplexMarker.center = CGPoint(x: self.view.frame.width / 2, y: Constant.topBarHeight + CGFloat(Constant.complexPanelOffset / 2) + 20)
        self.mapView.frame.origin.y = (self.view.frame.height - self.mapView.frame.height) / 2
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.mapView.frame.origin.y -= 120
        }
        mComplexMarker.backgroundColor = color
        mComplexMarker.alpha = 0
        mComplexMarker.layer.cornerRadius = mComplexMarker.frame.width / 2
        mComplexMarker.layer.removeAllAnimations()
        self.view.addSubview(mComplexMarker)
        UIView.animate(withDuration: 0.3) {
            self.mComplexMarker.alpha = 1
        } completion: { (finished: Bool) in
            self.animateComplexMarker()
        }
    }

    func animateComplexMarker()
    {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse])
        {
            self.mComplexMarker.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    func removeComplexMarker()
    {
        mComplexMarker.removeFromSuperview()
        mComplexMarker = nil
    }
    
    func addCameraMarkerWithAzimuth(azimuth: Float, state: Int)
    {
        var image: String = ""
        switch state
        {
        case 0:
            image = "camera-orange"
            break
        case 1:
            image = "camera-green"
            break
        case 2:
            image = "camera-red"
            break
        case 3:
            image = "camera-purple"
            break
        case 10:
            image = "camera-gray"
            break
        default:
            break
        }
        if mCameraMarker == nil
        {
            mCameraMarker = UIImageView.init(image: UIImage(named: image))
            mCameraMarker.center = CGPoint(x: self.view.frame.width / 2, y: Constant.topBarHeight + CGFloat(Constant.complexPanelOffset / 2))
            if image == "camera-gray"
            {
                mCameraMarker.center.y += 30
                
            }
            mCameraMarker.alpha = 0
            mCameraMarker.transform = CGAffineTransform(rotationAngle: CGFloat((azimuth - 180) * (Float.pi / 180)))
            mCameraMarker.layer.anchorPoint = CGPoint(x: mCameraMarker.layer.anchorPoint.x, y:  mCameraMarker.layer.anchorPoint.y + 0.39)
            self.view.addSubview(mCameraMarker)
        }
        
        mCameraMarker.image = UIImage(named: image)
        
        UIView.animate(withDuration: 0.3) {
            self.mCameraMarker.alpha = 1
            self.mCameraMarker.transform = CGAffineTransform(rotationAngle:  CGFloat((azimuth - 180) * (Float.pi / 180)))
        }
    }
    func removeCameraMarker()
    {
        if mCameraMarker != nil
        {
        mCameraMarker.removeFromSuperview()
        mCameraMarker = nil
        }
    }
    
    func complexWillShow(complex:Complex, animated: Bool)
    {
        self.clearMap()
        mapView.selectedMarker = nil
        self.addComplexMarkerWithColor(color: Constant.colors[Int(complex.workState)]!)

        UIView.animate(withDuration: animated ? 0.3 : 0) {
            print((self.view.frame.height - self.mapView.frame.height) / 2)
            self.mapView.frame.origin.y = (self.view.frame.height - self.mapView.frame.height) / 2
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.mapView.frame.origin.y -= 120
            }
        } completion: { (finished: Bool) in
            let coordinate = CLLocationCoordinate2DMake(complex.lat, complex.lng)
            let zoom:Float = 18
            let position: GMSCameraPosition = .camera(withTarget: coordinate, zoom: zoom)
            self.mapView.animate(to: position)
        }
        
    }
    
    
    func complexDidHide()
    {
        mapView.animate(toZoom: 17)
        self.clearMap()
        self.removeComplexMarker()
        self.addMarkers()
        self.addDummies()

        UIView.animate(withDuration: 0.3) {
            self.mapView.frame.origin.y = 0        }
    }
    
    func cameraWillShow(camera:Camera)
    {
        self.addCameraMarkerWithAzimuth(azimuth: Float(camera.azimuth), state: Int(camera.workState))
        self.mComplexMarker.isHidden = true
    }
    
    func cameraDidHide()
    {
        self.removeCameraMarker()
        mComplexMarker.isHidden = false
    }
    
    func dummyWillShow(dummy:Dummy, animated:Bool)
    {
        self.clearMap()
        mapView.selectedMarker = nil
        self.addCameraMarkerWithAzimuth(azimuth: Float(dummy.azimuth), state: Constant.dummy)

        UIView.animate(withDuration: animated ? 0.3 : 0)
        {
            self.mapView.frame.origin.y = (self.view.frame.height - self.mapView.frame.height) / 2
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.mapView.frame.origin.y -= 120
            }
        } completion: { (finished: Bool)  in
            let coordinate = CLLocationCoordinate2DMake(dummy.lat, dummy.lng)
            let zoom:Float = 18
            let position: GMSCameraPosition = .camera(withTarget: coordinate, zoom: zoom)
            self.mapView.animate(to: position)
            
        }
    }
    
    func dummyDidHide()
    {
        mapView.animate(toZoom: 17)
        self.clearMap()
        self.removeCameraMarker()
       
        self.addMarkers()
        self.addDummies()
        UIView.animate(withDuration: 0.3) {
            self.mapView.frame.origin.y = 0
        }
    }
    
    @objc func changeMapType() {
        
        let alert = UIAlertController(title: "Выберите тип карты", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Обычный", style: .default, handler:
                                        {_ in
                                            self.mapView.mapType = .normal
                                            let defaults = UserDefaults.standard
                                            defaults.setValue(0, forKey: Constant.mapType)
                                            defaults.synchronize()
                                        }))
        alert.addAction(UIAlertAction(title: "Спутник", style: .default, handler:
                                        {_ in
                                            self.mapView.mapType = .hybrid
                                            let defaults = UserDefaults.standard
                                            defaults.setValue(1, forKey: Constant.mapType)
                                            defaults.synchronize()
                                        }))

        self.present(alert, animated: true)
    }
    
    
    func showUserLocation()
    {
        if mUserLocation != nil && mUserLocation.coordinate.latitude != 0
        {
            let camera: GMSCameraPosition = .camera(withLatitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude, zoom: 12)
            mapView.animate(to: camera)
        }
    }
    
    func zoomInMap() {
        mapView.animate(toZoom: mapView.camera.zoom + 1)
    }
    func zoomOutMap() {
        mapView.animate(toZoom: mapView.camera.zoom - 1)
    }
    
    func complexOffsetDidChange(offset: Float)
    {

        mapView.frame.origin.y = (self.view.frame.height - mapView.frame.height) / 2 + (CGFloat(offset) / 2) - 20
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            mapView.frame.origin.y = (self.view.frame.height - mapView.frame.height) / 2 + (CGFloat(offset) / 2) - 120
        }
        
        mapView.animate(toZoom: 18 - offset / 30)
        if mComplexMarker != nil
        {
        mComplexMarker.center.y = (Constant.topBarHeight + CGFloat(Constant.complexPanelOffset / 2)) + CGFloat(offset) / 2
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                mComplexMarker.center.y = (Constant.topBarHeight + CGFloat(Constant.complexPanelOffset / 2)) + CGFloat(offset) / 2 + 20
            }
        }
        
        if  mCameraMarker != nil
        {
        mCameraMarker.center.y = (Constant.topBarHeight + CGFloat(Constant.complexPanelOffset / 2)) + CGFloat(offset) / 2
            if mComplexMarker != nil
            {
                mCameraMarker.center.y = (Constant.topBarHeight + CGFloat(Constant.complexPanelOffset / 2)) + CGFloat(offset) / 2 + 20
            }
        }
    }
    
   
    func addMarkers()
    {
        let algorithm: GMUClusterAlgorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let iconGenerator: GMUClusterIconGenerator = GMUDefaultClusterIconGenerator.init()
        let renderer = GMUDefaultClusterRenderer.init(mapView: self.mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        
        mComlexClusterManager =  GMUClusterManager.init(map: self.mapView, algorithm: algorithm, renderer: renderer)
        mComlexClusterManager.setDelegate(self, mapDelegate: self)
        
        let complexes: NSArray = CoreDataStack.sharedInstance.getComplexes(filters: mFilters).fetchedObjects! as NSArray
        
        for i in stride(from: 0, to: complexes.count, by: 1)
        {
            let complex: Complex = complexes[i] as! Complex
            let latitude: Double = complex.lat
            let longitude: Double = complex.lng
            if longitude > 85
            {
                print(longitude)
            }
            let item: GMUClusterItem = MarkerItem.init(position: CLLocationCoordinate2DMake(latitude, longitude), userData: complex)
            
            if latitude > 0 && latitude < 85 && longitude > 0 && longitude <  85
            {
//                print("latitude: \(latitude)","longitude: \(longitude)")
                self.mComlexClusterManager.add(item)
            }
            
            
        }
        mComlexClusterManager.cluster()
    }
    
    func addDummies()
    {
        let algorithm: GMUClusterAlgorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let iconGenerator: GMUClusterIconGenerator = GMUDefaultClusterIconGenerator.init()
        
        let renderer = GMUDefaultClusterRenderer.init(mapView: self.mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        mDummyClustermanager = GMUClusterManager.init(map: self.mapView, algorithm: algorithm, renderer: renderer)
        
        mDummyClustermanager.setDelegate(self, mapDelegate: self)
        
        let dummies: NSArray = CoreDataStack.sharedInstance.getDummies(filters: mFilters).fetchedObjects! as NSArray
        for i in stride(from: 0, to: dummies.count, by: 1)
        {
            let dummy: Dummy = dummies[i] as! Dummy
            let latitude: Double = dummy.lat
            let longitude: Double = dummy.lng
            
            let item: GMUClusterItem = MarkerItem.init(position: CLLocationCoordinate2DMake(latitude, longitude), userData: dummy)
           
                if latitude != 0.0 || longitude != 0.0
                {
                    self.mDummyClustermanager.add(item)
                }
        }
        mDummyClustermanager.cluster()
    }
    
    func clearMap()
    {
        mapView.clear()
        mDummyClustermanager.clearItems()
        mComlexClusterManager.clearItems()
    }
    
    @objc func updateMap()
    {
        let defaults = UserDefaults.standard
        defaults.setValue(1, forKey: Constant.showTabBarButtons)
        defaults.synchronize()
        
        self.clearMap()
        self.addMarkers()
        self.addDummies()
    }
    
    @objc func dataBaseUpdated()
    {
        if mComplexMarker == nil && mCameraMarker == nil
        {
            self.updateMap()
        }
    }
    
    func filtersChanged(filters: NSArray?) {
        mSelectedCompleName = ""
        mFilters = filters
        self.updateMap()
    }
    
    func selectComplex(complex: Complex)
    {
        mSelectedCompleName = complex.name
        if complex.lat != 0.0
        {
            let coordinate = CLLocationCoordinate2DMake(complex.lat, complex.lng)
            let zoom:Float = 17
            let position: GMSCameraPosition = .camera(withTarget: coordinate, zoom: zoom)
            mapView.animate(to: position)
        }
        else
        {
            self.pushComplexController(complex: complex)
        }
    }
    
    func addMultipleComplexTable()
    {
        mMultieComplexTable = TableView.init(withStyle: UITableView.Style.plain)
        mMultieComplexTable.frame = CGRect(x: 0, y: self.view.frame.height - 15, width: self.view.frame.width, height: self.view.frame.height / 2)
        mMultieComplexTable.mTableViewDelegate = self
        mMultieComplexTable.rowHeight = 60
        mMultieComplexTable.setCell(cell: MapMultipleComplexCell.self)
        
        mMultieComplexTable.setBlurWithoutStyle(size: CGSize.zero)
        self.view.addSubview(mMultieComplexTable)
        self.view.bringSubviewToFront(mMultieComplexTable)
    }
    
    
    func hideMultipleComplexTable()
    {
        UIView.animate(withDuration: 0.3) {
            self.mMultieComplexTable.frame.origin.y = self.view.frame.height
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath: IndexPath) {
        let cell = cell as! MapMultipleComplexCell

        let object1 = mSelectedMiltipleComlexesAndDummies.object(at: atIndexPath.row)
        

        if object1 is Complex
        {
            let complex:Complex = object1 as! Complex

            cell.setWorkState(workState: Int(complex.workState))
            cell.setName(type: complex.name ?? "")
            cell.setType(type: "Тип: \(complex.clName ?? "")")
            
        }
        else if object1 is Dummy
        {
            let dummy:Dummy = object1 as! Dummy

            cell.setWorkState(workState: Constant.dummy)
            cell.setName(type: dummy.name ?? "")
            cell.setType(type: "Тип: \(dummy.clName ?? "")")
            
        }
//        cell.setLineHidden(lineHidden: atIndexPath.row != 0)
//        cell.lineHidden = atIndexPath.row == 0
        cell.selected(false, animated: false)

    }
    func selectedCell(cell: UITableViewCell, atIndexPath: IndexPath) {
        let cell = cell as! MapMultipleComplexCell
        let object = mSelectedMiltipleComlexesAndDummies[atIndexPath.row]
        if object is Complex
        {
            let complex:Complex = object as! Complex
            self.pushComplexController(complex: complex)
        }
        else if object is Dummy
        {
            let dummy:Dummy = object as! Dummy
            self.pushDummyController(dummy: dummy)
        }

        cell.selected(true, animated: true)
        self.hideMultipleComplexTable()
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let coordinate = cluster.position
        let zoom:Float =  mapView.camera.zoom + 1
        let position: GMSCameraPosition = .camera(withTarget: coordinate, zoom: zoom)
        self.mapView.animate(to: position)
        self.hideMultipleComplexTable()
        
        return true
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        var icon: UIImage!
        if marker.userData is MarkerItem
        {
            let mark: MarkerItem = marker.userData as! MarkerItem
            let userData = mark.userData
            if userData is Complex
            {
                let complex: Complex = userData as! Complex
                let isDraft:Bool = complex.state == Constant.draft
                let nameCam = complex.clName ?? ""
                if nameCam != ""
                {
                let firstChar = nameCam[nameCam.startIndex].uppercased()
                let lastChar = nameCam[nameCam.index(before: nameCam.endIndex)].lowercased()
                let className = "\(firstChar)\(lastChar)"
                var type: String!
                switch Int(complex.workState) {
                case 0:
                    type = "map-marker-orange"
                    break
                case 1:
                    type = "map-marker-green"
                    break
                case 2:
                    type = "map-marker-red"
                    break
                case 3:
                    type = "map-marker-purple"
                    break
                default:
                    break
                }
                let name = "\(className)_" + type + "_\(isDraft)"
                icon = mMarkersIcons.value(forKey: name) as? UIImage
                if icon == nil
                {
                    icon = UIImage(named: type)!.setmarkerImage(drawText: className,
                                        font: Constant.setFontBold(size: 14),
                                        color: isDraft ? UIColor.WhiteAlpha : UIColor.White,
                                        alpha: isDraft ? 0.4 : 1,
                                        atPoint: CGPoint(x: -1, y: 10),
                                        circleColor: nil)
                    self.mMarkersIcons.setValue(icon, forKey: name)
                }
                }
                
            }
            
            else if userData is Dummy
            {
                icon = UIImage(named: "map-marker-gray")!
            }
        }
        else if let _ = marker.userData as? GMUCluster
        {
            let marker = marker.userData as! GMUCluster
            let markers = marker.items
            
            let states:NSMutableArray = []
            for item in stride(from: 0, to: markers.count, by: 1)
            {
                let userData = (markers[item] as! MarkerItem).userData
                if let _ = userData as? Complex
                {
                    let complex: Complex = userData as! Complex
                    states.add(complex.workState)
                }
                else if  let _ = userData as? Dummy
                {
                    states.add(Constant.dummy)
                }
            }
            icon = UIImage().pieChartWithArray(array: states,
                                               colors: Constant.colors as NSDictionary,
                                               radius: 25, stretch: true,
                                               sumColors: [UIColor.Black,
                                                           UIColor.White],
                                               borderColor: UIColor.White)
        }
        marker.icon = icon
    }
    
    func renderer(_ renderer: GMUClusterRenderer, didRenderMarker marker: GMSMarker) {
        if let _ = marker.userData as? MarkerItem
        {
            let complex = (marker.userData as! MarkerItem).userData as? Complex
            if complex?.name == mSelectedCompleName
            {
                mapView.selectedMarker = marker
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//        guard
            let complex = (marker.userData as! MarkerItem).userData
//                as? Complex
//        else {return UIView()}
//        if complex as? Complex != nil
//        {
//            complex = complex as! Complex
//        }
//        else
//        {
//            complex = complex as! Dummy
//        }
        mSelectedCompleName = ""
        mSelectedMiltipleComlexesAndDummies = CoreDataStack.sharedInstance.getComplexesAndDummiesByLatitude(lat: complex!.lat, lng: complex!.lng)
        var window: UIView?
        let count = mSelectedMiltipleComlexesAndDummies.count
        var height = CGFloat(count) * mMultieComplexTable.rowHeight + 20
        self.view.bringSubviewToFront(mMultieComplexTable)
        if count == 1
        {
            window = UIView.init()
            
            window!.frame.size = CGSize(width: 0, height: 34)
            window!.backgroundColor = UIColor.white
            
            let name = TapAndCopyLabel()
            name.labelWithFrame(frame: CGRect(x: 10, y: 0, width: 0, height: 0), colors: [UIColor.DarkGray ,UIColor.clear])
            name.text = complex!.name
            name.font = Constant.setMediumFont(size: 14)
            name.sizeToFit()
            name.center.y = window!.frame.height / 2
            marker.title = name.text
            
            window!.addSubview(name)
            
            let chevron: UIImageView = UIImageView(image: UIImage(named: "chevron-right"))
            chevron.frame.origin.x = name.frame.origin.x + name.frame.width + 30
            chevron.center.y = name.center.y
            window!.addSubview(chevron)

            window!.frame.size.width = chevron.frame.origin.x + chevron.frame.width + 10
            marker.infoWindowAnchor = CGPoint(x: 1 + ((window!.frame.width) / 2) * 0.0274, y: 0.72)

        }
        else
        {
            if height > self.view.frame.height / 2 - CGFloat(Constant.tabBarHeightConstant) + 10
            {
                height = self.view.frame.height / 2 - CGFloat(Constant.tabBarHeightConstant) + 10
            }
            self.mMultieComplexTable.setArray(array: mSelectedMiltipleComlexesAndDummies)
            self.mMultieComplexTable.update()
        }
        if count > 1
        {
            UIView.animate(withDuration: 0.3)
            {
                self.mMultieComplexTable.frame.size.height = height
                self.mMultieComplexTable.alpha = 1
                
                self.mMultieComplexTable.frame.origin.y = self.view.frame.height - (self.mMultieComplexTable.frame.height + CGFloat(Constant.tabBarHeightConstant))
                print(self.view.frame.height)
                print(self.mMultieComplexTable.frame.origin.y)
                self.mMultieComplexTable.isHidden = false
                
            }
        }
        else
        {
            self.hideMultipleComplexTable()
        }
        return window
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let userData = (marker.userData as! MarkerItem).userData
        
        if let _ = userData as? Complex
        {
            let complex: Complex = userData as! Complex
            self.pushComplexController(complex: complex)
        }
        else if let _ = userData as? Dummy
        {
            let dummy: Dummy = userData as! Dummy
            self.pushDummyController(dummy: dummy)        }
        
    }
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker)
    {
        let userData = (marker.userData as! MarkerItem).userData
        UIPasteboard.general.string = marker.title ?? ""
        mDelegate?.showCopyAlertlabel(text: "\(marker.title ?? "")")
    }
     
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mSelectedCompleName = ""
        self.hideMultipleComplexTable()
        mDelegate?.hideSearchPanel()
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        mDelegate?.hideSearchPanel()
    }

    func pushComplexController(complex: Complex)
    {
        mSelectedCompleName = ""
        if complex.lat != 0.0
        {
            self.complexWillShow(complex: complex, animated: true)
        }
       
        let complexController: ComplexController = ComplexController(withComplex: complex)
        complexController.mDelegate = self
        mDelegate?.pushViewController(controlelr: complexController)
    }
    func pushDummyController(dummy: Dummy)
    {
        mSelectedCompleName = ""
        if dummy.lat != 0.0
        {
            self.dummyWillShow(dummy: dummy, animated: true)
        }
        
        let dummyController: DummyController = DummyController(withDummy: dummy)

        dummyController.mDelegate = self
        mDelegate?.pushViewController(controlelr: dummyController)
    }
    func enableMyLocation()
    {
            self.requestLocationAuthorization()
    }
    
    func requestLocationAuthorization()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else {
          return
        }
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
      }
    
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
          return
        }
        mUserLocation = location
        locationManager.stopUpdatingLocation()
      }

}
