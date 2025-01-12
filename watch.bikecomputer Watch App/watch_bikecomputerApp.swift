//
//  watch_bikecomputerApp.swift
//  watch.bikecomputer Watch App
//
//  Created by Bill, Yiu Por Chan on 05/01/2025.
//

import SwiftUI

@main
struct WatchBikeComputerApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        ContentView()
          .tabItem {
            Label("Workout", systemImage: "bicycle")
          }
        
        FileListView()
          .tabItem {
            Label("Files", systemImage: "folder")
          }
      }
    }
  }
}
