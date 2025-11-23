// RemoteImageView.swift
// SwiftUI view for loading remote images asynchronously

import SwiftUI

struct RemoteImageView: View {
  let url: URL
  let imageLoader: ImageLoader
  let placeholderColor: Color?
  
  @State private var image: UIImage?
  @State private var isLoading = false
  @State private var error: Error?
  
  init(url: URL, imageLoader: ImageLoader, placeholderColor: Color? = nil) {
    self.url = url
    self.imageLoader = imageLoader
    self.placeholderColor = placeholderColor
  }
  
  var body: some View {
    Group {
      if let image {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
      } else if isLoading {
        (placeholderColor ?? Color.gray.opacity(0.2))
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
      if image == nil && !isLoading {
        Task {
          await loadImage()
        }
      }
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
