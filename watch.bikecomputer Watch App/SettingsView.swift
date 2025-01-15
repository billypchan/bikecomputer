//
//  SettingsView.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 12/01/2025.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("useMorseCode") private var useMorseCode: Bool = false
    @AppStorage("speakInterval") private var speakInterval: TimeInterval = 60 // Default is 1 minute
    
    var body: some View {
        Form {
            Section(header: Text("Speak Interval")) {
                Picker("Interval", selection: $speakInterval) {
                    Text("30 Seconds").tag(30.0)
                    Text("1 Minute").tag(60.0)
                    Text("2 Minutes").tag(120.0)
                }
                //                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Feedback Settings")) {
                Toggle(isOn: $useMorseCode) {
                    Text("Use Morse Code for Speed")
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                if !useMorseCode {
                    Text("Speed will be spoken aloud.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    Text("Speed will be communicated via Morse code.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    // Show Morse Code Table
                    MorseCodeTableView(morseCodeMapping: MorseCodeService.morseCodeMapping)
                }
            }
            
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .previewDevice("Apple Watch Series 8 - 45mm") // Adjust the device if necessary
  }
}
