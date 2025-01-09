//
//  WorkoutManager.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 06/01/2025.
//

import HealthKit

// MARK: - WorkoutManager
class WorkoutManager: NSObject {
  private let healthStore = HKHealthStore()
  private var workoutSession: HKWorkoutSession?
  private var builder: HKLiveWorkoutBuilder?
  
  weak var locationManager: LocationManager?
  private var maxSpeed: Double = 0.0
  private var totalSpeed: Double = 0.0
  private var speedCount: Int = 0
  
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
      
      // Reset speed data
      maxSpeed = 0.0
      totalSpeed = 0.0
      speedCount = 0
      
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
        let metadata = [
          "MaxSpeed": maxSpeed,
          "AvgSpeed": speedCount > 0 ? totalSpeed / Double(speedCount) : 0.0
        ] as [String: Any]
        await saveWorkoutRoute(for: workout, metadata: metadata)
      }
    } catch {
      print("Failed to stop workout: \(error.localizedDescription)")
    }
  }
  
  private func saveWorkoutRoute(for workout: HKWorkout, metadata: [String: Any]) async {
    guard let locations = locationManager?.locations, !locations.isEmpty else {
      print("No locations available to save.")
      return
    }
    
    let workoutRouteBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
    
    do {
      // Filter out low-accuracy locations if needed
      try await workoutRouteBuilder.insertRouteData(locations)
      try await workoutRouteBuilder.finishRoute(with: workout, metadata: metadata)
      print("Workout route saved successfully with metadata: \(metadata)")
    } catch {
      print("Failed to save workout route: \(error.localizedDescription)")
    }
  }
  
  func updateSpeed(_ speed: Double) {
    // This function should be called whenever the speed is updated
    maxSpeed = max(maxSpeed, speed)
    totalSpeed += speed
    speedCount += 1
  }
}
