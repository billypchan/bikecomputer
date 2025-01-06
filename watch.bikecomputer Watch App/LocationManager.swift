//
//  LocationManager.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 06/01/2025.
//

import CoreLocation


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  
  @Published var speed: Double = 0.0
  @Published var speedAccuracy: Double = 0.0

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    speed = location.speed * 3.6
    speedAccuracy = location.speedAccuracy
    
    if speed < 0 {
      speed = .nan
    }
    print("speed: \(location.speed)")
    print("speedAccuracy: \(location.speedAccuracy)")
  }
}
