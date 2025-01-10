//
//  CLLocationArrayTests.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 09/01/2025.
//


import XCTest
import CoreLocation

@testable import watch_bikecomputer_Watch_App

class CLLocationArrayTests: XCTestCase {
  
  func testMaxSpeed() {
    let locations: [CLLocation] = [
      CLLocation(coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
                 altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10,
                 course: 0, speed: 5.5, timestamp: Date()),
      CLLocation(coordinate: CLLocationCoordinate2D(latitude: 52.5201, longitude: 13.4051),
                 altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10,
                 course: 0, speed: 7.2, timestamp: Date()),
      CLLocation(coordinate: CLLocationCoordinate2D(latitude: 52.5202, longitude: 13.4052),
                 altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10,
                 course: 0, speed: 6.3, timestamp: Date())
    ]
    
    XCTAssertEqual(locations.maxSpeed, 7.2, accuracy: 0.001, "Max speed should be 7.2")
  }
  
  func testAverageSpeed() {
    let locations: [CLLocation] = [
      CLLocation(coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
                 altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10,
                 course: 0, speed: 5.5, timestamp: Date()),
      CLLocation(coordinate: CLLocationCoordinate2D(latitude: 52.5201, longitude: 13.4051),
                 altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10,
                 course: 0, speed: 7.2, timestamp: Date()),
      CLLocation(coordinate: CLLocationCoordinate2D(latitude: 52.5202, longitude: 13.4052),
                 altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10,
                 course: 0, speed: 6.3, timestamp: Date())
    ]
    
    XCTAssertEqual(locations.averageSpeed, 6.333, accuracy: 0.001, "Average speed should be approximately 6.333")
  }
  
  func testNoValidSpeeds() {
    let locations: [CLLocation] = [
      CLLocation(coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
                 altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10,
                 course: 0, speed: -1, timestamp: Date())
    ]
    
    XCTAssertEqual(locations.maxSpeed, 0.0, "Max speed should be 0.0 for no valid speeds")
    XCTAssertEqual(locations.averageSpeed, 0.0, "Average speed should be 0.0 for no valid speeds")
  }
}
