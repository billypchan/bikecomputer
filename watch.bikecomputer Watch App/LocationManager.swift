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

  var locations: [CLLocation] = [] // To store workout route data

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  // MARK: - CLLocationManagerDelegate
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    self.locations.append(contentsOf: locations)

    guard let location = locations.last else { return }
    
    speed = location.speed * 3.6
    speedAccuracy = location.speedAccuracy
    
    print("speed: \(location.speed)")
    print("speedAccuracy: \(location.speedAccuracy)")
    print("coordinate: \(location.coordinate)")

  }
}
