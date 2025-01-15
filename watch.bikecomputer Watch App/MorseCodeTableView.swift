//
//  MorseCodeTableView.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 15/01/2025.
//

import SwiftUI

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
