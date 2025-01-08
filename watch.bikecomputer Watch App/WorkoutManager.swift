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
  
  func requestAuthorization() {
    let typesToShare: Set = [
      HKObjectType.workoutType(),
      HKSeriesType.workoutRoute()
    ]
    
    let typesToRead: Set = [
      HKObjectType.quantityType(forIdentifier: .heartRate)!,
      HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
      if !success {
        if let error = error {
          print("HealthKit authorization failed: \(error.localizedDescription)")
        } else {
          print("HealthKit authorization was not granted by the user.")
        }
      } else {
        print("HealthKit authorization succeeded.")
      }
    }
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
      
      // Clear previous location data if needed
      // locationManager?.locations.removeAll()
      
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
    
    let workoutRouteBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
    
    do {
      try await workoutRouteBuilder.insertRouteData(locations)
      try await workoutRouteBuilder.finishRoute(with: workout, metadata: nil)
      print("Workout route saved successfully.")
    } catch {
      print("Failed to save workout route: \(error.localizedDescription)")
    }
  }
}
