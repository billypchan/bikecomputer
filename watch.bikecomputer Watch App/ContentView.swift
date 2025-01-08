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
    private let lengthFormatter = LengthFormatter()
    
    var body: some View {
        VStack {
            Text("Speed")
                .font(.callout)
            
            if currentSpeed.isNaN || currentSpeed < 0 {
                Text("--")
                    .foregroundColor(.gray)
            } else {
                Text("\(currentSpeed, specifier: "%.1f") km/h")
                    .font(.title)
                    .bold()
                    .padding()
                    .foregroundColor(speedColor(for: currentSpeedAccuracy))
            }
            
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading) {
                TimelineView(.animation) { context in
                    Text("Duration: \(formatDuration(duration))")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                }
                .onReceive(workoutTimer) { _ in
                    if isWorkoutActive {
                        duration += 1
                    }
                }
                
                Text("Distance: \(formattedDistance(totalDistance))")
                    .font(.title3)
                    .bold()
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
            workoutManager.requestAuthorization()
        }
    }
    
    private func toggleWorkout() {
        isWorkoutActive.toggle()
        if isWorkoutActive {
            workoutManager.startWorkout()
            duration = 0.0
            totalDistance = 0.0
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
    
    private func formattedDistance(_ meters: Double) -> String {
        lengthFormatter.unitStyle = .short
        return lengthFormatter.string(fromMeters: meters)
    }
    
    private func speedColor(for accuracy: Double) -> Color {
        switch accuracy {
            case ..<5:
                return .green // High accuracy
            case 5..<10:
                return .orange // Medium accuracy
            default:
                return .red // Low accuracy
        }
    }
}
#Preview {
    ContentView()
}
