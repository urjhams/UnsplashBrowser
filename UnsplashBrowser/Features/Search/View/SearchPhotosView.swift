// SearchPhotosView.swift
// SwiftUI view with LazyVGrid for photo search

import SwiftUI
import Swinject

struct SearchPhotosView: View {
  @Environment(\.resolver) private var resolver
  @Environment(\.isRunningOniPad) private var isIpad
  @Environment(\.imageLoader) private var imageLoader
  
  @State private var viewModel: SearchPhotosViewModel?
  @State private var searchText = ""
  @State private var searchTask: Task<Void, Never>?
  @Namespace private var detailNamespace
  
  private var columns: [GridItem] {
    let columnCount = isIpad ? 5 : 3
    return Array(repeating: GridItem(.flexible()), count: columnCount)
  }
  
  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        Group {
          if let viewModel {
            contentView(viewModel: viewModel, geometry: geometry)
          } else {
            EmptyView()
          }
        }
      }
      .navigationTitle("Search Photos")
      .searchable(text: $searchText, prompt: "Search for photos...")
      .onChange(of: searchText) { _, newValue in
        searchTask?.cancel()
        searchTask = Task {
          try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 second debounce
          guard !Task.isCancelled else {
            return
          }
          await viewModel?.search(query: newValue)
        }
      }
      .task {
        if viewModel == nil, let apiClient = resolver.resolve(UnsplashAPIClient.self) {
          viewModel = SearchPhotosViewModel(apiClient: apiClient)
        }
      }
    }
  }
}

extension SearchPhotosView {
  @ViewBuilder
  private func contentView(viewModel: SearchPhotosViewModel, geometry: GeometryProxy) -> some View {
    if viewModel.photos.isEmpty {
      if searchText.isEmpty {
        emptyStateView
      } else if let message = viewModel.message {
        messageView(message: message, isError: !viewModel.isLoading)
      } else {
        emptyStateView
      }
    } else {
      photosGrid(viewModel: viewModel, geometry: geometry)
    }
  }

  private var emptyStateView: some View {
    ContentUnavailableView(
      "Search for Photos",
      systemImage: "magnifyingglass",
      description: Text("Enter a keyword to search Unsplash photos")
    )
  }

  private func messageView(message: String, isError: Bool) -> some View {
    ContentUnavailableView(
      isError ? "Error" : "Search for Photos",
      systemImage: isError ? "exclamationmark.triangle" : "magnifyingglass",
      description: Text(message)
    )
  }

  private func photosGrid(viewModel: SearchPhotosViewModel, geometry: GeometryProxy) -> some View {
    let columnCount = CGFloat(columns.count)
    let spacing: CGFloat = 4
    let totalSpacing = spacing * (columnCount + 1)
    let availableWidth = geometry.size.width - totalSpacing
    let cellSize = availableWidth / columnCount
    
    return ScrollView {
      LazyVGrid(columns: columns, spacing: spacing) {
        ForEach(viewModel.photos) { photo in
          if let loader = imageLoader, let thumb = URL(string: photo.urls.thumb) {
            photoLink(of: photo, viewModel: viewModel, loader: loader, thumb: thumb, size: cellSize)
          }
        }
      }
      .padding(spacing)

      if viewModel.isLoading {
        ProgressView()
          .padding()
      }
    }
    .navigationDestination(for: UnsplashPhoto.self) { photo in
      PhotoDetailView(photo: photo)
        .navigationTransition(.zoom(sourceID: photo.id, in: detailNamespace))
    }
  }
  
  @ViewBuilder
  private func photoLink(
    of photo: UnsplashPhoto,
    viewModel: SearchPhotosViewModel,
    loader: any ImageLoader,
    thumb: URL,
    size: CGFloat
  ) -> some View {
    NavigationLink(value: photo) {
      photoCellImageView(of: photo, loader: loader, thumbURL: thumb, size: size)
        .matchedTransitionSource(id: photo.id, in: detailNamespace)
    }
    .transition(.opacity)
    .onAppear {
      // Preload when reaching 10 items before the end
      if
        let index = viewModel.photos.firstIndex(where: { $0.id == photo.id }),
        index >= viewModel.photos.count - 10 {
        Task {
          await viewModel.loadMore()
        }
      }
    }
  }
  
  @ViewBuilder
  private func photoCellImageView(
    of photo: UnsplashPhoto,
    loader: any ImageLoader,
    thumbURL: URL, size: CGFloat
  ) -> some View {
    let color = photo.color.map(Color.init(hex:))
    RemoteImageView(url: thumbURL, placeholderColor: color)
      .aspectRatio(1, contentMode: .fill)
      .frame(width: size, height: size)
      .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}
