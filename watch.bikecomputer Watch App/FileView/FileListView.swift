//
//  FileListView.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 12/01/2025.
//


import SwiftUI

struct FileListView: View {
  @State private var files: [FileInfo] = []
  
  var body: some View {
    List(files) { file in
      NavigationLink(destination: LocationMapView(fileName: file.name)) {
        HStack {
          VStack(alignment: .leading) {
            Text(file.name)
              .font(.headline)
            Text(file.formattedSize)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          Spacer()
        }
      }
    }
    .navigationTitle("Stored Files")
    .onAppear(perform: loadFiles)
  }
  
  private func loadFiles() {
    do {
      let fileManager = FileManager.default
      let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)
      
      files = fileURLs
        .map { url in
          let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
          return FileInfo(
            name: url.lastPathComponent,
            size: size
          )
        }
        .sorted { $0.name > $1.name } // Sort by name descending
    } catch {
      print("Failed to load files: \(error.localizedDescription)")
    }
  }
}

struct FileInfo: Identifiable {
  let id = UUID()
  let name: String
  let size: Int
  
  var formattedSize: String {
    ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
  }
}
