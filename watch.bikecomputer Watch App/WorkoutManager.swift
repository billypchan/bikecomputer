//
//  WorkoutManager.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 06/01/2025.
//

// MARK: - WorkoutManager
import Combine
import HealthKit
import CoreLocation

class WorkoutManager: NSObject, ObservableObject {
  private let healthStore = HKHealthStore()
  private var workoutSession: HKWorkoutSession?
  private var builder: HKLiveWorkoutBuilder?
  private var workoutRouteBuilder: HKWorkoutRouteBuilder?
  
  weak var locationManager: LocationManager?
  private var cancellables = Set<AnyCancellable>()
  
  private var locations: [CLLocation] = [] // To store workout route data

  
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
    
    locations.removeAll()
    
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .cycling
    configuration.locationType = .outdoor
    
    workoutRouteBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
    
    do {
      workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
      builder = workoutSession?.associatedWorkoutBuilder()
      builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
      
      workoutSession?.startActivity(with: Date())
      try await builder?.beginCollection(at: Date())
      
      observeLocationUpdates()
      
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
  
  private func observeLocationUpdates() {
    locationManager?.$updateLocations
      .sink { [weak self] locations in
        guard let self = self,
              let workoutRouteBuilder = self.workoutRouteBuilder,
              !locations.isEmpty else { return }
        
        let filteredLocations = locations.filter { $0.horizontalAccuracy <= 50.0 }
        
        Task {
          do {
            self.locations.append(contentsOf: filteredLocations)
            
            try await workoutRouteBuilder.insertRouteData(filteredLocations)
            print("Inserted \(filteredLocations.count) new location(s) into workout route.")
          } catch {
            print("Failed to insert route data: \(error.localizedDescription)")
          }
        }
      }
      .store(in: &cancellables)
  }
  
  private func saveWorkoutRoute(for workout: HKWorkout) async {
    
    do {
      try await workoutRouteBuilder?.finishRoute(with: workout, metadata: nil)
    } catch {
      print("Failed to save workout route: \(error.localizedDescription)")
    }
  }
}
