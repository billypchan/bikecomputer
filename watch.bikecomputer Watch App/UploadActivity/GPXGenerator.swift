//
//  GPXGenerator.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 11/01/2025.
//


import Foundation
import CoreLocation


/// ref: https://developers.strava.com/docs/uploads/
struct GPXGenerator {
    static func generateGPX(from locations: [CLLocation], activityName: String) -> URL? {
        let gpxHeader = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="BillBikeComputer" xmlns="http://www.topografix.com/GPX/1/1">
        <trk><name>\(activityName)</name><trkseg>
        """
        
        let gpxFooter = """
        </trkseg></trk></gpx>
        """
        
        let gpxBody = locations.map { location in
            """
            <trkpt lat="\(location.coordinate.latitude)" lon="\(location.coordinate.longitude)">
            <ele>\(location.altitude)</ele>
            <time>\(ISO8601DateFormatter().string(from: location.timestamp))</time>
            </trkpt>
            """
        }.joined(separator: "\n")
        
        let gpxContent = gpxHeader + gpxBody + gpxFooter
        
        do {
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent("\(activityName).gpx")
            try gpxContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing GPX file: \(error)")
            return nil
        }
    }
}
