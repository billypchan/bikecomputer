//
//  SpeechService.swift
//  zonevirbrate Watch App
//
//  Created by Bill, Yiu Por Chan on 14.10.23.
//

import Foundation
import AVFAudio
import AVFoundation

final class SpeechService: ObservableObject {
  private let synthesizer = AVSpeechSynthesizer()
  
  func speak(sentence: String) {
    let utterance = AVSpeechUtterance(string: sentence)
    
    let code: String
    // Dynamically set the voice based on the system language
    if let systemLanguageCode = Locale.current.language.languageCode?.identifier {
      code = systemLanguageCode
    } else {
      // Fallback to a default voice if the system language isn't supported
      code = "en-US"
    }
    utterance.voice = AVSpeechSynthesisVoice(language: code)
    
    
    synthesizer.speak(utterance)
  }
}

