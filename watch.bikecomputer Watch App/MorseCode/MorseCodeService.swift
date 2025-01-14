//
//  MorseCodeService.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 12/01/2025.
//


import AVFoundation

import AVFoundation

class MorseCodeService {
  private var dotPlayer: AVAudioPlayer?
  private var dashPlayer: AVAudioPlayer?
  
  private let dotDuration: TimeInterval = 0.1
  private let dashDuration: TimeInterval = 0.3
  private let pauseDuration: TimeInterval = 0.2
  
  static let morseCodeMapping: [Character: String] = [
    "0": "-",
    "1": ".-",
    "2": "..-",
    "3": "...-",
    "4": "....-",
    "5": ".....",
    "6": "-....",
    "7": "-...",
    "8": "-..",
    "9": "-."
  ]
  
  init() {
    loadSoundFiles()
  }
  
  /// Preloads the sound files into audio players for reuse.
  private func loadSoundFiles() {
    if let dotURL = Bundle.main.url(forResource: "dot", withExtension: "m4a") {
      dotPlayer = try? AVAudioPlayer(contentsOf: dotURL)
      dotPlayer?.prepareToPlay()
    } else {
      print("Dot sound file not found.")
    }
    
    if let dashURL = Bundle.main.url(forResource: "dash", withExtension: "m4a") {
      dashPlayer = try? AVAudioPlayer(contentsOf: dashURL)
      dashPlayer?.prepareToPlay()
    } else {
      print("Dash sound file not found.")
    }
  }
  
  func playMorseCode(for speed: Int) {
    let speedString = String(speed)
    
    Task {
      for char in speedString {
        guard let morseCode = MorseCodeService.morseCodeMapping[char] else { continue }
        
        for symbol in morseCode {
          if symbol == "." {
            playDot()
          } else if symbol == "-" {
            playDash()
          }
          // Add a pause between symbols
          try? await Task.sleep(nanoseconds: 200_000_000) // 200 ms pause
        }
        
        // Add a longer pause between characters
        try? await Task.sleep(nanoseconds: 600_000_000) // 600 ms pause
      }
    }
  }
  
  /// Plays the preloaded sound for a dot.
  func playDot() {
    dotPlayer?.currentTime = 0 // Reset to the beginning
    dotPlayer?.play()
  }
  
  /// Plays the preloaded sound for a dash.
  func playDash() {
    dashPlayer?.currentTime = 0 // Reset to the beginning
    dashPlayer?.play()
  }
}

#if DEBUG
import SwiftUI

struct MorseCodePreviewView: View {
  private var morseCodeService = MorseCodeService()
  
  var body: some View {
    VStack(spacing: 20) {
      Button("Play 4") {
        morseCodeService.playMorseCode(for: 4)
      }
      .buttonStyle(.borderedProminent)
      .tint(.green)
      Button("Play 25") {
        morseCodeService.playMorseCode(for: 25)
      }
      .buttonStyle(.borderedProminent)
      .tint(.green)
      Button("Play 6") {
        morseCodeService.playMorseCode(for: 6)
      }
      .buttonStyle(.borderedProminent)
      .tint(.green)
      Button("Play Dot") {
        morseCodeService.playDot()
      }
      .buttonStyle(.borderedProminent)
      .tint(.green)
      
      Button("Play Dash") {
        morseCodeService.playDash()
      }
      .buttonStyle(.borderedProminent)
      .tint(.blue)
    }
    .padding()
    .navigationTitle("Morse Code Preview")
  }
}

struct MorseCodePreviewView_Previews: PreviewProvider {
  static var previews: some View {
    MorseCodePreviewView()
      .previewDevice("Apple Watch Series 8 - 45mm")
  }
}
#endif
