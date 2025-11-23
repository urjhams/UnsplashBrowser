// SearchPhotosViewModel.swift
// @Observable class managing search state and pagination

import Foundation

@MainActor
@Observable
class SearchPhotosViewModel {
  private let apiClient: UnsplashAPIClient

  var photos: [UnsplashPhoto] = []
  var isLoading = false
  var message: String?
  var searchQuery = ""
  private var currentPage = 1
  private var hasMorePages = true
  private var loadTask: Task<Void, Never>?
  private var loadedPhotoIDs = Set<String>()

  init(apiClient: UnsplashAPIClient) {
    self.apiClient = apiClient
  }
  
  func lastRowIndex(_ photoPerRow: Int) -> Int {
    photos.count > photoPerRow ? photoPerRow - photoPerRow : photos.count - 1
  }

  func search(query: String) async {
    guard !query.isEmpty else {
      photos = []
      return
    }

    loadTask?.cancel()
    loadTask = nil
    searchQuery = query
    currentPage = 1
    hasMorePages = true
    isLoading = true
    message = "Searching for \"\(query)\"..."
    loadedPhotoIDs.removeAll()

    do {
      let response = try await apiClient.searchPhotos(
        query: query,
        page: currentPage,
        perPage: 30
      )
      photos = response.results
      hasMorePages = currentPage < response.totalPages
      loadedPhotoIDs = Set(photos.map { $0.id })
      
      if photos.isEmpty {
        message = "No photos found for \"\(query)\""
      } else {
        message = nil
      }
    } catch {
      message = error.localizedDescription
      photos = []
    }

    isLoading = false
  }

  func loadMore() async {
    guard !isLoading && hasMorePages && !searchQuery.isEmpty else {
      return
    }
    
    // Prevent concurrent load operations
    guard loadTask == nil else {
      return
    }

    loadTask = Task { @MainActor in
      isLoading = true
      currentPage += 1

      do {
        let response = try await apiClient.searchPhotos(
          query: searchQuery,
          page: currentPage,
          perPage: 20
        )
        
        // Filter out duplicates before appending
        let newPhotos = response.results.filter { !loadedPhotoIDs.contains($0.id) }
        photos.append(contentsOf: newPhotos)
        loadedPhotoIDs.formUnion(newPhotos.map { $0.id })
        
        hasMorePages = currentPage < response.totalPages
      } catch {
        message = error.localizedDescription
        currentPage -= 1
      }

      isLoading = false
      loadTask = nil
    }
    
    await loadTask?.value
  }
}
