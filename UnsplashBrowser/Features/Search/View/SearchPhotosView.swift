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
    let columnCount = isIpad ? 4 : 2
    return Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
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
    if viewModel.photos.isEmpty && !viewModel.isLoading {
      if searchText.isEmpty {
        emptyStateView
      } else if viewModel.errorMessage != nil {
        errorView(message: viewModel.errorMessage!)
      } else {
        noResultsView
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

  private var noResultsView: some View {
    ContentUnavailableView.search(text: searchText)
  }

  private func errorView(message: String) -> some View {
    ContentUnavailableView(
      "Error",
      systemImage: "exclamationmark.triangle",
      description: Text(message)
    )
  }

  private func photosGrid(viewModel: SearchPhotosViewModel) -> some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(viewModel.photos) { photo in
          NavigationLink(value: photo) {
            photoCell(photo: photo)
              .matchedTransitionSource(id: photo.id, in: detailNamespace)
          }
          .buttonStyle(.plain)
          .onAppear {
            if photo.id == viewModel.photos.last?.id {
              Task {
                await viewModel.loadMore()
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
          
      } else {
        EmptyView()
      }
    }
  }

  @ViewBuilder
  private func photoCell(photo: UnsplashPhoto) -> some View {
    let aspectRatio = CGFloat(photo.width) / CGFloat(photo.height)
    let placeholderColor = photo.color.map { Color(hex: $0) }
    if let thumbnailURL = URL(string: photo.urls.small), let imageLoader {
      RemoteImageView(url: thumbnailURL, imageLoader: imageLoader, placeholderColor: placeholderColor)
        .aspectRatio(aspectRatio, contentMode: .fill)
        .frame(height: isIpad ? 200 : 150)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .navigationTransition(.zoom(sourceID: photo.id, in: searchNamespace))
    } else {
      EmptyView()
    }
  }

  @Namespace private var searchNamespace
}
