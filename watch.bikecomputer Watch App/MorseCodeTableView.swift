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
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(morseCodeMapping.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    VStack {
                        Text(String(key))
                            .fontWeight(.bold)
                        Text(value)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

struct MorseCodeTableView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                MorseCodeTableView(
                    morseCodeMapping: [
                        "A": ".-", "B": "-...", "C": "-.-.",
                        "D": "-..", "E": ".", "F": "..-.",
                        "G": "--.", "H": "....", "I": "..",
                        "J": ".---", "K": "-.-", "L": ".-..",
                        "M": "--", "N": "-.", "O": "---",
                        "P": ".--.", "Q": "--.-", "R": ".-.",
                        "S": "...", "T": "-", "U": "..-",
                        "V": "...-", "W": ".--", "X": "-..-",
                        "Y": "-.--", "Z": "--..", "1": ".----",
                        "2": "..---", "3": "...--", "4": "....-",
                        "5": ".....", "6": "-....", "7": "--...",
                        "8": "---..", "9": "----.", "0": "-----"
                    ]
                )
            }
            .navigationTitle("Morse Code Table")
        }
    }
}
