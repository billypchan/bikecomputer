//
//  WorkoutManager.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 06/01/2025.
//

import HealthKit
import CoreLocation

// MARK: - WorkoutManager
class WorkoutManager: NSObject {
  private let healthStore = HKHealthStore()
  private var workoutSession: HKWorkoutSession?
  private var builder: HKLiveWorkoutBuilder?
  
  weak var locationManager: LocationManager?
  
  func requestAuthorization() async throws {
    let typesToShare: Set = [
      HKObjectType.workoutType(),
      HKSeriesType.workoutRoute()
    ]
    
    let typesToRead: Set = [
      HKObjectType.quantityType(forIdentifier: .heartRate)!,
      HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    print("HealthKit authorization succeeded.")
  }
  
  func startWorkout() async {
    guard HKHealthStore.isHealthDataAvailable() else { return }
    
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .cycling // Cycling provides speed data
    configuration.locationType = .outdoor
    
    do {
      workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
      builder = workoutSession?.associatedWorkoutBuilder()
      builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
      
      
      workoutSession?.startActivity(with: Date())
      try await builder?.beginCollection(at: Date())
      
      print("Workout session started and collection began.")
    } catch {
      print("Failed to start workout session: \(error.localizedDescription)")
    }
  }
  
  func stopWorkout() async {
    workoutSession?.end()
    
    do {
      try await builder?.endCollection(at: Date())
      if let workout = try await builder?.finishWorkout() {
        await saveWorkoutRoute(for: workout)
      }
    } catch {
      print("Failed to stop workout: \(error.localizedDescription)")
    }
  }
  
  private func saveWorkoutRoute(for workout: HKWorkout) async {
    guard let locations = locationManager?.locations, !locations.isEmpty else {
      print("No locations available to save.")
      return
    }
    
    // Filter the raw data.
    let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
      location.horizontalAccuracy <= 50.0
    }
    
    let maxSpeed = filteredLocations.maxSpeed
    let avgSpeed = filteredLocations.averageSpeed
    let metadata = [
      HKMetadataKeyMaximumSpeed: maxSpeed,
      HKMetadataKeyAverageSpeed: avgSpeed
    ] as [String: Any]

    let workoutRouteBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
    
    do {
      // Filter out low-accuracy locations if needed
      try await workoutRouteBuilder.insertRouteData(filteredLocations)
      try await workoutRouteBuilder.finishRoute(with: workout, metadata: metadata)
      print("Workout route saved successfully with metadata: \(metadata)")
    } catch {
      print("Failed to save workout route: \(error.localizedDescription)")
    }
  }
  
}

extension Array where Element == CLLocation {
  /// Finds the maximum speed in the array of locations.
  var maxSpeed: Double {
    self.compactMap { $0.speed >= 0 ? $0.speed : nil }.max() ?? 0.0
  }
  
  /// Calculates the average speed from the array of locations.
  var averageSpeed: Double {
    let validSpeeds = self.compactMap { $0.speed >= 0 ? $0.speed : nil }
    guard !validSpeeds.isEmpty else { return 0.0 }
    return validSpeeds.reduce(0.0, +) / Double(validSpeeds.count)
  }
}
