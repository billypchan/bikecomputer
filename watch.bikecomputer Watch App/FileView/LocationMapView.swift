//
//  LocationMapView.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 12/01/2025.
//

import SwiftUI
import MapKit
import CoreLocation
import CLLocationWrapper

// FIXME: file format check, error handling
struct LocationMapView: View {
  let fileName: String
  @State private var locations: [CLLocation] = []
  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
  )
  
  var body: some View {
    Group {
        Map(coordinateRegion: $region, annotationItems: locations) { loc in
          MapMarker(
            coordinate: CLLocationCoordinate2D(
              latitude: loc.coordinate.latitude,
              longitude: loc.coordinate.longitude
            )
          )
        }
      }
    .navigationTitle(fileName)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear(perform: loadLocation)
  }
  
  private func loadLocation() {
//    do {
//      let fileManager = FileManager.default
//      let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//      let fileURL = documentsURL.appendingPathComponent(fileName)
//      
//      let data = try Data(contentsOf: fileURL)
//      print(String(data: data, encoding: .utf8))
//      let decodedLocation = try JSONDecoder().decode([CLLocation].self, from: data)
//      locations = decodedLocation
//      
//      // Update region to center on the loaded location
//      region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(
//          latitude: decodedLocation.latitude,
//          longitude: decodedLocation.longitude
//        ),
//        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//      )
//    } catch {
//      print("Failed to load location data: \(error.localizedDescription)")
//    }
  }
}

// Keep EncodableLocation the same as before
extension CLLocation: Identifiable {
  public var id: String {
    "\(coordinate.latitude)-\(coordinate.longitude)-\(timestamp)"
  }
}
