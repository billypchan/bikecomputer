//
//  MorseCodeService.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 12/01/2025.
//


import AVFoundation
import WatchKit

class MorseCodeService {
  private var audioPlayer: AVAudioPlayer?
  
  private let dotDuration: TimeInterval = 0.1
  private let dashDuration: TimeInterval = 0.3
  private let pauseDuration: TimeInterval = 0.2
  private let frequency: Double = 440.0 // Frequency of the beep sound
  
  let morseCodeMapping: [Character: String] = [
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
  
  func playMorseCode(for speed: Int) {
    let speedString = String(speed)
    
    Task {
      for char in speedString {
        // Convert the Character to a String for dictionary lookup
        guard let morseCode = morseCodeMapping[char] else { continue }
        
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
  
  /// Plays the stored sound file for a dot.
  /// sounds recorded from https://elucidation.github.io/MorsePy/
  func playDot() {
    guard let soundURL = Bundle.main.url(forResource: "dot", withExtension: "m4a") else {
      print("Dot sound file not found.")
      return
    }
    playSound(from: soundURL)
  }
  
  /// Plays the stored sound file for a dash.
  func playDash() {
    guard let soundURL = Bundle.main.url(forResource: "dash", withExtension: "m4a") else {
      print("Dash sound file not found.")
      return
    }
    playSound(from: soundURL)
  }
  
  /// Helper function to play a sound file.
  private func playSound(from url: URL) {
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
    } catch {
      print("Failed to play sound: \(error.localizedDescription)")
    }
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
