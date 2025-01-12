//
//  SettingsView.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 12/01/2025.
//


import SwiftUI

struct SettingsView: View {
  @AppStorage("useMorseCode") private var useMorseCode: Bool = false
  
  
  var body: some View {
    Form {
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

struct MorseCodeTableView: View {
  let morseCodeMapping: [Character: String]
  
  var body: some View {
    Section(header: Text("Morse Code Table")) {
      ForEach(morseCodeMapping.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
        HStack {
          Text(String(key))
            .fontWeight(.bold)
          Spacer()
          Text(value)
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.secondary)
        }
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .previewDevice("Apple Watch Series 8 - 45mm") // Adjust the device if necessary
  }
}
