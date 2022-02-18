////
////  MyLocation.swift
////  ККВФ
////
////  Created by Акифьев Максим  on 19.07.2021.
////
//
//import Foundation
//import UIKit
//import GoogleMaps
//
//extension MapViewController: CLLocationManagerDelegate {
//  // 2
//  func locationManager(
//    _ manager: CLLocationManager,
//    didChangeAuthorization status: CLAuthorizationStatus
//  ) {
//    // 3
//    guard status == .authorizedWhenInUse else {
//      return
//    }
//    // 4
//    locationManager.requestLocation()
//
//    //5
//    mapView.isMyLocationEnabled = true
//    mapView.settings.myLocationButton = false
//  }
//
//  // 6
//  func locationManager(
//    _ manager: CLLocationManager,
//    didUpdateLocations locations: [CLLocation]) {
//    guard let location = locations.first else {
//      return
//    }
//
//    // 7
////    mapView.camera = GMSCameraPosition(
////      target: location.coordinate,
////      zoom: 15,
////      bearing: 0,
////      viewingAngle: 0)
//  }
//
//  // 8
//  func locationManager(
//    _ manager: CLLocationManager,
//    didFailWithError error: Error
//  ) {
//    print(error)
//  }
//}
