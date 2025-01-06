//
//  ContentView.swift
//  watch.bikecomputer Watch App
//
//  Created by Bill, Yiu Por Chan on 05/01/2025.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var locationManager = LocationManager()
  
  @State private var currentSpeed: Double = 0.0
  @State private var currentSpeedAccuracy: Double = 0.0
  @State private var isWorkoutActive: Bool = false
  @State private var totalDistance: Double = 0.0
  @State private var duration: TimeInterval = 0.0
  
  private var workoutManager = WorkoutManager()
  private var workoutTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  var body: some View {
    VStack {
      Text("Speed")
        .font(.headline)
      
      if currentSpeed.isNaN || currentSpeed < 0 {
        Text("--")
      } else {
        Text("\(currentSpeed, specifier: "%.1f") km/h")
          .font(.caption)
          .bold()
          .padding()
      }
      
      Text("Accuracy: \(currentSpeedAccuracy, specifier: "%.2f")")
      
      Divider()
        .padding(.vertical)
      
      HStack {
        VStack(alignment: .leading) {
          Text("Duration")
            .font(.subheadline)
          Text("\(formatDuration(duration))")
            .font(.title3)
            .bold()
        }
        
        Spacer()
        
        VStack(alignment: .leading) {
          Text("Distance")
            .font(.subheadline)
          Text("\(totalDistance, specifier: "%.2f") km")
            .font(.title3)
            .bold()
        }
      }
      .padding(.horizontal)
      
      Spacer()
      
      Button(action: toggleWorkout) {
        Text(isWorkoutActive ? "Stop" : "Start")
          .font(.headline)
          .padding()
          .frame(maxWidth: .infinity)
          .background(isWorkoutActive ? .red : .green)
          .foregroundColor(.white)
          .cornerRadius(10)
      }
      .buttonStyle(BorderButtonStyle())
      .padding(.horizontal)
    }
    .padding()
    .onReceive(locationManager.$speed) { speed in
      currentSpeed = speed
    }
    .onReceive(locationManager.$speedAccuracy) { newValue in
      currentSpeedAccuracy = newValue
    }
    .onReceive(locationManager.$distance) { distance in
      totalDistance = distance / 1000.0 // Convert meters to kilometers
    }
    .onReceive(workoutTimer) { _ in
      if isWorkoutActive {
        duration += 1
      }
    }
    .onAppear {
      workoutManager.locationManager = locationManager
      workoutManager.requestAuthorization()
    }
  }
  
  private func toggleWorkout() {
    isWorkoutActive.toggle()
    if isWorkoutActive {
      workoutManager.startWorkout()
      duration = 0.0 // Reset duration
      totalDistance = 0.0 // Reset distance
      locationManager.startUpdatingLocation()
    } else {
      workoutManager.stopWorkout()
      locationManager.stopUpdatingLocation()
    }
  }
  
  private func formatDuration(_ seconds: TimeInterval) -> String {
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    let seconds = Int(seconds) % 60
    if hours > 0 {
      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    } else {
      return String(format: "%02d:%02d", minutes, seconds)
    }
  }
}

#Preview {
  ContentView()
}
