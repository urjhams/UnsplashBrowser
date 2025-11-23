// SearchPhotosView.swift
// SwiftUI view with LazyVGrid for photo search

import SwiftUI
import Swinject

struct SearchPhotosView: View {
  @Environment(\.resolver) private var resolver
  @Environment(\.isRunningOniPad) private var isIpad

  @State private var viewModel: SearchPhotosViewModel?
  @State private var searchText = ""
  @State private var searchTask: Task<Void, Never>?
  @Namespace private var detailNamespace

  private var imageLoader: ImageLoader? {
    resolver.resolve(ImageLoader.self)
  }

  private var columns: [GridItem] {
    let columnCount = isIpad ? 4 : 3
    return Array(repeating: GridItem(.flexible()), count: columnCount)
  }

  var body: some View {
    NavigationStack {
      Group {
        if let viewModel {
          contentView(viewModel: viewModel)
        } else {
          ProgressView()
        }
      }
      .navigationTitle("Search Photos")
      .searchable(text: $searchText, prompt: "Search for photos...")
      .onChange(of: searchText) { _, newValue in
        searchTask?.cancel()
        searchTask = Task {
          try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 second debounce
          guard !Task.isCancelled else { return }
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

  @ViewBuilder
  private func contentView(viewModel: SearchPhotosViewModel) -> some View {
    if viewModel.photos.isEmpty {
      if searchText.isEmpty {
        emptyStateView
      } else if let message = viewModel.message {
        messageView(message: message, isError: !viewModel.isLoading)
      } else {
        emptyStateView
      }
    } else {
      photosGrid(viewModel: viewModel)
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

  private func photosGrid(viewModel: SearchPhotosViewModel) -> some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(viewModel.photos) { photo in
          if let loader = imageLoader, let thumb = URL(string: photo.urls.small) {
            NavigationLink(value: photo) {
              photoCell(photo: photo, loader: loader, thumbURL: thumb)
                .matchedTransitionSource(id: photo.id, in: detailNamespace)
            }
            .onAppear {
              if photo.id == viewModel.photos.last?.id {
                Task {
                  await viewModel.loadMore()
                }
              }
            }
          }
        }
      }
      .padding()

      if viewModel.isLoading {
        ProgressView()
          .padding()
      }
    }
    .navigationDestination(for: UnsplashPhoto.self) { photo in
      if let imageLoader {
        PhotoDetailView(photo: photo, imageLoader: imageLoader)
          .navigationTransition(.zoom(sourceID: photo.id, in: detailNamespace))
          
      }
    }
  }

  @ViewBuilder
  private func photoCell(photo: UnsplashPhoto, loader: any ImageLoader, thumbURL: URL) -> some View {
    let color = photo.color.map { Color(hex: $0) }
    // TODO: use GeometryReader to make correct value for .frame
    RemoteImageView(url: thumbURL, imageLoader: loader, placeholderColor: color)
      .aspectRatio(1, contentMode: .fill)
      .frame(width: 300, height: 300)
      .clipShape(RoundedRectangle(cornerRadius: 8))
  }

  @Namespace private var searchNamespace
}
