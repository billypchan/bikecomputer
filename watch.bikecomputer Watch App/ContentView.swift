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

//  private let healthStore = HKHealthStore()
  private var workoutManager = WorkoutManager()

  var body: some View {
    VStack {
      Text("Speed")
        .font(.headline)

      if currentSpeed.isNaN {
        Text("--")
      } else {
        Text("\(currentSpeed, specifier: "%.1f") km/h")
          .font(.largeTitle)
          .bold()
          .padding()
          .onReceive(locationManager.$speed) { speed in
            currentSpeed = speed
          }
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
          .background(isWorkoutActive ? Color.red : Color.green)
          .foregroundColor(.white)
          .cornerRadius(10)
      }
      .buttonStyle(BorderButtonStyle())
    }
    .padding()
    .onReceive(locationManager.$speedAccuracy) { newValue in
      currentSpeedAccuracy = newValue
    }
    .onAppear {
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
