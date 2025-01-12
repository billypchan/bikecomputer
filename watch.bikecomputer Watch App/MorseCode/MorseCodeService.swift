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
  
//  func playSpeedAsMorseCode(speed: Double) {
//    let morseCode = speedToMorseCode(speed: speed)
//    playMorseCode(morseCode)
//  }
//  
//  func speedToMorseCode(speed: Double) -> String {
//    let speedString = String(format: "%.0f", speed) // Convert to 1 decimal place
//    return speedString.compactMap { morseCodeMapping[$0] ?? ($0 == "." ? "." : nil) }.joined(separator: " ")
//  }
  
  func playMorseCode(for speed: Int) {
    guard let morseCode = morseCodeMapping[String(speed).first ?? "0"] else { return }
    
    Task {
      for symbol in morseCode {
        if symbol == "." {
          playDot()
        } else if symbol == "-" {
          playDash()
        }
        // Add a pause between symbols
        try? await Task.sleep(nanoseconds: 200_000_000) // 200 ms pause
      }
    }
  }
  
  //    private func playBeep(duration: TimeInterval) {
  //        let soundID: SystemSoundID = 1005 // Default beep
  //        AudioServicesPlaySystemSoundWithCompletion(soundID) {
  //            Thread.sleep(forTimeInterval: duration)
  //        }
  //    }
  
  private func playDot() {
    WKInterfaceDevice.current().play(.click)
  }
  
  private func playDash() {
    WKInterfaceDevice.current().play(.success)
  }
}
