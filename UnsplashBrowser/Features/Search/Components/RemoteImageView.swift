// RemoteImageView.swift
// SwiftUI view for loading remote images asynchronously

import SwiftUI

struct RemoteImageView: View {
  let url: URL
  let imageLoader: ImageLoader
  
  @State private var image: UIImage?
  @State private var isLoading = false
  @State private var error: Error?
  
  var body: some View {
    Group {
      if let image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else if isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if error != nil {
        Image(systemName: "photo")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.secondary)
          .padding()
      } else {
        Color.gray.opacity(0.2)
      }
    }
    .task(id: url) {
      await loadImage()
    }
  }
  
  private func loadImage() async {
    isLoading = true
    error = nil
    
    do {
      let loadedImage = try await imageLoader.loadImage(from: url)
      image = loadedImage
    } catch {
      self.error = error
    }
    
    isLoading = false
  }
}
