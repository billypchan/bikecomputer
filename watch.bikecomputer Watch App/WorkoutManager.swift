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
  
//  init(locationManager: LocationManager) {
//    self.locationManager = locationManager
//  }
  
  func requestAuthorization() {
    let typesToShare: Set = [
      HKObjectType.workoutType()
    ]
    
    let typesToRead: Set = [
      HKObjectType.quantityType(forIdentifier: .heartRate)!,
      HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
      if !success {
        print("Failed to get HealthKit authorization: \(String(describing: error))")
      }
    }
  }
  
  func startWorkout() {
    guard HKHealthStore.isHealthDataAvailable() else { return }
    
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .walking
    configuration.locationType = .outdoor
    
    do {
      workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
      builder = workoutSession?.associatedWorkoutBuilder()
      builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
//      locationManager?.locations.removeAll()
      workoutSession?.startActivity(with: Date())
      builder?.beginCollection(withStart: Date()) { success, error in
        if !success {
          print("Failed to begin workout collection: \(String(describing: error))")
        } else {
          print("beginCollection done")
        }
      }
    } catch {
      print("Failed to start workout session: \(error)")
    }
  }
    
  func stopWorkout() {
    workoutSession?.end()
    
    builder?.endCollection(withEnd: Date()) { [weak self] success, error in
      if success {
        self?.builder?.finishWorkout { workout, error in
          if let workout {
            self?.saveWorkoutRoute(for: workout)
          } else if let error = error {
            print("Failed to finish workout: \(error)")
          }
        }
      } else if let error = error {
        print("Failed to end workout collection: \(error)")
      }
    }
  }
  
  private func saveWorkoutRoute(for workout: HKWorkout) {
    guard let locations = locationManager?.locations, !locations.isEmpty else {
      print("no locations")
      return
    }
    
    let workoutRouteBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
    
    workoutRouteBuilder.insertRouteData(locations) { success, error in
      if success {
        workoutRouteBuilder.finishRoute(with: workout, metadata: nil) { _, error in
          if let error = error {
            print("Failed to save workout route: \(error)")
          }
        }
      } else if let error = error {
        print("Failed to insert route data: \(error)")
      }
    }
  }
}
