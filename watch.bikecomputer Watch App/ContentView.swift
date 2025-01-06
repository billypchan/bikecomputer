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

  private var workoutManager = WorkoutManager()

  var body: some View {
    VStack {
      Text("Speed")
        .font(.headline)

      if currentSpeed.isNaN || currentSpeed < 0 {
        Text("--")
      } else {
        Text("\(currentSpeed, specifier: "%.1f")km/h")
          .font(.caption)
          .bold()
          .padding()
      }

      Text("Accuracy: ")
      +
      Text("\(currentSpeedAccuracy, specifier: "%.2f")")
      
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
    }
    .padding()
    .onReceive(locationManager.$speed) { speed in
      currentSpeed = speed
    }
    .onReceive(locationManager.$speedAccuracy) { newValue in
      currentSpeedAccuracy = newValue
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
    } else {
      workoutManager.stopWorkout()
    }
  }
}

#Preview {
  ContentView()
}
