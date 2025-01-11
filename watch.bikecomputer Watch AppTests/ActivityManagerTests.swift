//
//  ActivityManagerTests.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 11/01/2025.
//

import XCTest
import CoreLocation

@testable import watch_bikecomputer_Watch_App

final class ActivityManagerTests: XCTestCase {
  var activityManager: ActivityManager!
  
  override func setUp() {
    super.setUp()
    activityManager = ActivityManager()
  }
  
  override func tearDown() {
    activityManager = nil
    super.tearDown()
  }
  
  func testGPXGenerationAndUpload() async {
    // Mock location data
    let mockLocations = [
      CLLocation(
        coordinate: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954),
        altitude: 34.0,
        horizontalAccuracy: 5.0,
        verticalAccuracy: 5.0,
        timestamp: Date()
      ),
      CLLocation(
        coordinate: CLLocationCoordinate2D(latitude: 52.520180, longitude: 13.405123),
        altitude: 36.0,
        horizontalAccuracy: 5.0,
        verticalAccuracy: 5.0,
        timestamp: Date().addingTimeInterval(60)
      )
    ]
    
    activityManager.locations = mockLocations
    
    // Generate the GPX file
    let gpxFileURL = GPXGenerator.generateGPX(from: mockLocations, activityName: "Test Activity")
    XCTAssertNotNil(gpxFileURL, "GPX file should be generated successfully.")
    
    // Mock the upload
    do {
      let response = try await MockStravaAPI.uploadGPX(fileURL: gpxFileURL!, accessToken: "mockAccessToken", activityName: "Test Activity")
      guard let httpResponse = response as? HTTPURLResponse else {
        XCTFail("Response should be HTTPURLResponse.")
        return
      }
      XCTAssertEqual(httpResponse.statusCode, 201, "Mock upload should return a 201 Created status.")
    } catch {
      XCTFail("Mock upload should not throw an error: \(error)")
    }
  }
}
