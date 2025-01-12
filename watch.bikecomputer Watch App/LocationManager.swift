//
//  LocationManager.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 06/01/2025.
//

import CoreLocation
//import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private var previousLocation: CLLocation?
  
  @Published var speed: Double = 0.0
  @Published var speedAccuracy: Double = 0.0
  @Published var distance: Double = 0.0 // Distance in meters

  //var locations: [CLLocation] = [] // To store workout route data
  var updateLocations: [CLLocation] = []

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
  func startUpdatingLocation() {
    distance = 0.0
    previousLocation = nil
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    updateLocations = locations
//    self.locations.append(contentsOf: locations)

    guard let location = locations.last else { return }
    
    speed = location.speed * 3.6 // Convert m/s to km/h
    speedAccuracy = location.speedAccuracy
    
    if let previousLocation {
      distance += location.distance(from: previousLocation) // Calculate distance in meters
    }
    self.previousLocation = location
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location update failed: \(error)")
  }
}
