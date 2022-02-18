//
//  StreetViewController.swift
//  StreetViewController
//
//  Created by Акифьев Максим  on 04.10.2021.
//

import Foundation
import GoogleMaps
import UIKit
import WebKit
import CoreLocation

class StreetViewController: UIViewController, WKNavigationDelegate, GMSPanoramaViewDelegate
{
    var mLoadingIndicator: UIActivityIndicatorView!
    var mBackGround: UIView!
    var mGooglePanorama: GMSPanoramaView!
    var mYandexPanorama: WKWebView!
    var mPanoramaType: Int!
    var mName: String!
    var mAddress: String!

    var mAzimuth: Int!
    var mCoordinate: CLLocationCoordinate2D!

    init(withComplex:Complex)
    {
        super.init(nibName: nil, bundle: nil)
        mName = withComplex.name
        mAddress = withComplex.placeName
       
        let camera:Camera = CoreDataStack.sharedInstance.getCameraInComplex(complex: Int(withComplex.id))!
            
        mAzimuth = Int(camera.azimuth)
        mCoordinate = CLLocationCoordinate2D(latitude: withComplex.lat, longitude: withComplex.lng)
        mCoordinate = coordinateFromCoord(fromCoord: mCoordinate, distanceKm: 0.01, bearingDegrees: Double(mAzimuth + 180))
        
    }

    init(withDummy:Dummy)
    {
        super.init(nibName: nil, bundle: nil)
        mName = withDummy.name
        mAddress = withDummy.placeName
        mAzimuth = Int(withDummy.azimuth)
        mCoordinate = CLLocationCoordinate2D(latitude: withDummy.lat, longitude: withDummy.lng)
        mCoordinate = self.coordinateFromCoord(fromCoord: mCoordinate, distanceKm: 0.01, bearingDegrees: Double(mAzimuth * 180))
    }
    
    func coordinateFromCoord(fromCoord: CLLocationCoordinate2D, distanceKm: Double, bearingDegrees: Double) -> CLLocationCoordinate2D
    {
        let distanceRadians:Double = distanceKm / 6371
        let bearingRadians:Double = Constant.degreesToRadians(degrees: bearingDegrees)
        let fromLatRadians:Double = Constant.degreesToRadians(degrees: fromCoord.latitude)
        let fromLonRadians:Double = Constant.degreesToRadians(degrees: fromCoord.longitude)

        let toLatRadians = asin(sin(fromLatRadians) * cos(distanceRadians) + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians))
        var toLonRadians = fromLonRadians + atan2(sin(bearingRadians) * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians) - sin(fromLatRadians) * sin(toLatRadians))
        toLonRadians = fmod((toLonRadians + (3 * Double.pi)), (2 * Double.pi)) - Double.pi

        return CLLocationCoordinate2DMake(Constant.radiansToDegrees(radians: toLatRadians), Constant.radiansToDegrees(radians: toLonRadians))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.navigationItem.title = "КВФ \(mName ?? "")"
        if mAzimuth != nil
        {
        self.view = UIView(frame: Constant.mainFrame)
        self.view.backgroundColor = .clear
        self.edgesForExtendedLayout = []

        let defaults = UserDefaults.standard
        mPanoramaType = defaults.integer(forKey: Constant.panoramaType)

        addViews()
        if mPanoramaType == 1
        {
            self.addGooglePanorama()
        }
        else
        {
            self.addGooglePanorama()
//            self.addYandexPanorama()
        }
        let changePanoramaTypeButton = UIBarButtonItem(image: UIImage(named: "panorama-toggle"), style: .done, target: self, action: #selector(changePanoramaType))
        self.navigationItem.setRightBarButton(changePanoramaTypeButton, animated: true)
        }
        else
        {
            
        }
    }

    func addViews()
    {
        let addressPanel = UIView()
        let address = UILabel()
        address.labelWithFrame(frame: .zero, colors: [UIColor.DarkGray, UIColor.clear])
        address.frame.origin.y = 10
        address.frame.size.width = self.view.frame.width - 20
        address.text = mAddress == nil ? "Нет данных" : mAddress
        address.font = Constant.setMediumFont(size: 14)
        address.textAlignment = .center
        address.sizeToFit()
        address.center.x = self.view.frame.width / 2
        addressPanel.addSubview(address)

        addressPanel.frame.size = CGSize(width: self.view.frame.width, height: address.frame.height + 20 + CGFloat(Constant.iPhoneXTabBarCoefficient))
        addressPanel.frame.origin.y = self.view.frame.height - addressPanel.frame.height - Constant.topBarHeight
        addressPanel.setBlur()
        self.view.addSubview(addressPanel)

        mBackGround = UIView(frame: Constant.mainFrame)
        mBackGround.frame.size.height = addressPanel.frame.origin.y
        mBackGround.backgroundColor = UIColor.Black

        self.view.addSubview(mBackGround)
        self.view.sendSubviewToBack(mBackGround)

        mLoadingIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            mLoadingIndicator.style = .medium
        } else {
            mLoadingIndicator.style = .white
        }
        mLoadingIndicator.color = .white
        mLoadingIndicator.center = CGPoint(x: mBackGround.frame.width / 2, y: mBackGround.frame.height / 2)
        mBackGround.addSubview(mLoadingIndicator)
    }
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D)
    {
        print(error)
    }
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama?) {
        if panorama?.panoramaID == nil
        {
            print("Error")
        }
    }
    
    func addGooglePanorama()
    {
        mLoadingIndicator.stopAnimating()
        mGooglePanorama = GMSPanoramaView.panorama(withFrame: mBackGround.frame, nearCoordinate: mCoordinate)
        self.view.addSubview(mGooglePanorama)
    }

    func addYandexPanorama()
    {
        mLoadingIndicator.startAnimating()

        mYandexPanorama = WKWebView(frame: mBackGround.frame)
        mYandexPanorama.backgroundColor = UIColor.clear
        mYandexPanorama.isOpaque = false
        mYandexPanorama.scrollView.showsVerticalScrollIndicator = false
        mYandexPanorama.scrollView.isScrollEnabled = false
        mYandexPanorama.navigationDelegate = self
        let url = URL(string: Constant.getYandexPanoramaURL(latitude: mCoordinate.latitude, longitude: mCoordinate.longitude, bearing: Double(mAzimuth)))!
        let request = URLRequest(url: url)
        mYandexPanorama.load(request)
        self.view.addSubview(mYandexPanorama)

        if Constant.IOS9
        {
            let longPress = UILongPressGestureRecognizer(target: nil, action: nil)
            longPress.minimumPressDuration = 0.2
            mYandexPanorama.addGestureRecognizer(longPress)
        }
    }

    func changePanorama(panoramaType: Int)
    {
        let panorama1 = panoramaType == 1 ? mGooglePanorama : mYandexPanorama
        let panorama2 = panoramaType == 1 ? mYandexPanorama : mGooglePanorama

        if panoramaType == 1
        {
            self.addGooglePanorama()
        }
        else
        {
            self.addGooglePanorama()
//            self.addYandexPanorama()
        }

        panorama1?.alpha = 1
        panorama2?.alpha = 0

        UIView.animate(withDuration: 0.3)
        {
            panorama1?.alpha = 0
            panorama2?.alpha = 1
        } completion:
        {(finished: Bool) in
            panorama1?.removeFromSuperview()
        }
    }

   @objc func changePanoramaType()
    {
        var panoramaType: Int!
        let alert = UIAlertController(title: "Выберите тип панорамы", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Google", style: .default, handler:
                                        {_ in
            panoramaType = 1
//            self.changePanorama(panoramaType: panoramaType)
                                            self.addGooglePanorama()
            let defaults = UserDefaults.standard
            defaults.setValue(panoramaType, forKey: Constant.panoramaType)
            defaults.synchronize()
                                        }))
//        alert.addAction(UIAlertAction(title: "Яндекс", style: .default, handler:
//                                        {_ in
//            panoramaType = 1
//            self.changePanorama(panoramaType: panoramaType)
//            let defaults = UserDefaults.standard
//            defaults.setValue(panoramaType, forKey: Constant.panoramaType)
//            defaults.synchronize()
//                                        }))
        self.present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url:String? = navigationAction.request.mainDocumentURL?.absoluteString
        if url != nil
        {
            if !(url == "about:blank") && !(url!.contains("api-maps.yandex.ru"))
            {
                decisionHandler(WKNavigationActionPolicy.allow)
            }
            else
            {
                decisionHandler(WKNavigationActionPolicy.allow)
            }
        }
        else
        {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }

    override var shouldAutorotate: Bool
    {
        return false
    }
}
