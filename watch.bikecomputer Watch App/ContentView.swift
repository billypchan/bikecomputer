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
  @State private var timer: Timer? // Reference to the Timer

  private lazy var workoutManager = WorkoutManager()
  private let lengthFormatter = LengthFormatter()
  private lazy var speechService = SpeechService()
  private lazy var morseCodeService = MorseCodeService()
  
  
  var body: some View {
    VStack {
      Text("Speed")
        .font(.callout)
      
      if currentSpeed.isNaN || currentSpeed < 0 {
        Text("--")
          .foregroundColor(.gray)
      } else {
        Text("\(currentSpeed, specifier: "%.1f")")
          .monospacedDigit()
          .font(.title)
          .bold()
          .foregroundColor(speedColor(for: currentSpeedAccuracy))
        + Text(" km/h")
          .font(.callout)
          .foregroundColor(speedColor(for: currentSpeedAccuracy))
      }
      
      Divider()
      
      VStack(alignment: .leading, spacing: 4) {
        TimelineView(.animation) { context in
          let elapsedTime = isWorkoutActive ? Date().timeIntervalSince(startTime ?? Date()) : duration
          Text("Duration: ")
            .monospacedDigit()
            .font(.callout)
            .foregroundColor(.secondary)
          + Text(DateComponentsFormatter.formattedWorkoutDuration(seconds: elapsedTime, unitsStyle: .positional))
            .font(.headline)
            .bold()
            .foregroundColor(.primary)
        }
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Distance: ")
            .monospacedDigit()
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
        locationManager.startUpdatingLocation()
        await workoutManager.startWorkout()
        startTime = Date() // Set start time
        totalDistance = 0.0 // Reset distance
        startMinuteTimer()
      }
    } else {
      Task {
        await workoutManager.stopWorkout()
        duration = Date().timeIntervalSince(startTime ?? Date()) // Save final duration
        locationManager.stopUpdatingLocation()
        startTime = nil // Clear start time
        stopMinuteTimer()
      }
    }
  }
  
  private func formattedDistance(_ meters: Double) -> String {
    lengthFormatter.unitStyle = .short
    lengthFormatter.numberFormatter.maximumFractionDigits = meters > 1000 ? 1 : 0
    
    return lengthFormatter.string(fromMeters: meters)
  }
  
  private func speedColor(for accuracy: Double) -> Color {
    switch accuracy {
      case ..<0:
        return .red // Low accuracy
      case 0..<1:
        return .primary // high accuracy
      default:
        return .orange // medium accuracy
    }
  }
  
  private func startMinuteTimer() {
    //FIXME: setting for speak interval
    timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
      
      speakSpeedIfNeeded()
    }
  }
    
  private func stopMinuteTimer() {
    timer?.invalidate()
    timer = nil // Remove the reference to the invalidated timer
  }
  
  private func speakSpeedIfNeeded() {
    let newSpeed: Double = currentSpeed
    let now = Date()
    let timeInterval = now.timeIntervalSince(lastSpokenTime)
    
    guard timeInterval >= 60 else { return }
    
    let useMorseCode: Bool = UserDefaults.standard.bool(forKey: "useMorseCode")
    
    if useMorseCode {
      if newSpeed > 0 {
        morseCodeService.playMorseCode(for: Int(newSpeed))
      }
    } else {
      
      // Only speak if:
      // 1. At least 1 minute has passed since the last spoken speed, AND
      // 2. The new speed differs from the last spoken speed by at least 1 km/h
      var sentence: String
      if newSpeed < 0 {
        sentence = "no signal"
      } else {
        // Speak the new speed
        sentence = "\(Int(newSpeed))"
        
        switch currentSpeedAccuracy {
          case 0..<1.5: // accurate speed
            break
          default:
            sentence = "about".localized + " \(sentence)"
        }
        sentence = "speed".localized + " \(sentence)."
      }
      
      speechService.speak(sentence: sentence)
      lastSpokenSpeed = newSpeed
      lastSpokenTime = now
    }
  }
  
}

#Preview {
  ContentView()
}
