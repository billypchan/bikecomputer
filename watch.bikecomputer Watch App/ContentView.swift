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
  @State private var startTime: Date? = nil
  @State private var duration: TimeInterval = 0.0
  
  @State private var lastSpokenSpeed: Double = -1
  @State private var lastSpokenTime: Date = Date()

  private var workoutManager = WorkoutManager()
  private let lengthFormatter = LengthFormatter()
  private let speechService = SpeechService()
  
  
  var body: some View {
    VStack {
      Text("Speed")
        .font(.callout)
      
      if currentSpeed.isNaN || currentSpeed < 0 {
        Text("--")
          .foregroundColor(.gray)
      } else {
        Text("\(currentSpeed, specifier: "%.1f")")
          .font(.title)
          .bold()
          .foregroundColor(speedColor(for: currentSpeedAccuracy))
        + Text(" km/h")
          .font(.callout)
          .foregroundColor(speedColor(for: currentSpeedAccuracy))
      }
      
      Divider()
//        .padding(.vertical)
      
      VStack(alignment: .leading, spacing: 4) {
        TimelineView(.animation) { context in
          let elapsedTime = isWorkoutActive ? Date().timeIntervalSince(startTime ?? Date()) : duration
          Text("Duration: ")
            .font(.callout)
            .foregroundColor(.secondary)
          + Text(DateComponentsFormatter.formattedWorkoutDuration(seconds: elapsedTime, unitsStyle: .positional))
            .font(.headline)
            .bold()
            .foregroundColor(.primary)
        }
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Distance: ")
            .font(.callout)
            .foregroundColor(.secondary)
          + Text(formattedDistance(totalDistance))
            .font(.headline)
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
          .background(isWorkoutActive ? Color.red : Color.green)
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
      totalDistance = distance
    }
    .onAppear {
      workoutManager.locationManager = locationManager
      Task {
        try await workoutManager.requestAuthorization()
      }
    }
  }
  
  private func toggleWorkout() {
    isWorkoutActive.toggle()
    if isWorkoutActive {
      Task {
        await workoutManager.startWorkout()
        startTime = Date() // Set start time
        totalDistance = 0.0 // Reset distance
              locationManager.startUpdatingLocation()
      }
    } else {
      Task {
        await workoutManager.stopWorkout()
        duration = Date().timeIntervalSince(startTime ?? Date()) // Save final duration
        locationManager.stopUpdatingLocation()
        startTime = nil // Clear start time
      }
    }
  }
  
  private func formattedDistance(_ meters: Double) -> String {
    lengthFormatter.unitStyle = .short
    lengthFormatter.numberFormatter.maximumFractionDigits = 1
    
    return lengthFormatter.string(fromMeters: meters)
  }
  
  private func speedColor(for accuracy: Double) -> Color {
    switch accuracy {
      case ..<0:
        return .red // Low accuracy
      case 0..<3:
        return .primary // high accuracy
      default:
        return .orange // medium accuracy
    }
  }
  
  private func speakSpeedIfNeeded(newSpeed: Double) {
    let now = Date()
    let timeInterval = now.timeIntervalSince(lastSpokenTime)
    
    // Only speak if:
    // 1. At least 1 minute has passed since the last spoken speed, AND
    // 2. The new speed differs from the last spoken speed by at least 1 km/h
    if timeInterval >= 60 && abs(newSpeed - lastSpokenSpeed) >= 1.0 {
      // Speak the new speed
      var sentence = "\(Int(newSpeed))"
      
      switch currentSpeedAccuracy {
        case 0..<1.5: // accurate speed
          break
        default:
          sentence = "about".localized + " \(sentence)"
      }
      
      sentence = "speed".localized + " \(sentence)."
      
      speechService.speak(sentence: sentence)
      lastSpokenSpeed = newSpeed
      lastSpokenTime = now
    }
  }
}

#Preview {
  ContentView()
}
