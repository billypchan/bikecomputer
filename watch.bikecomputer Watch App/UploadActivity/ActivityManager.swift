//
//  ActivityManager.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 11/01/2025.
//


import CoreLocation

class ActivityManager {
    var locations: [CLLocation] = []
    var accessToken: String = "YOUR_ACCESS_TOKEN"
    
    func stopActivity() async {
        guard let gpxFileURL = GPXGenerator.generateGPX(from: locations, activityName: "My Activity") else {
            print("Failed to generate GPX file.")
            return
        }
        
        do {
            let response = try await StravaAPI.uploadGPX(fileURL: gpxFileURL, accessToken: accessToken, activityName: "My Activity")
            print("Uploaded to Strava successfully: \(response)")
        } catch {
            print("Error uploading to Strava: \(error)")
        }
    }
}