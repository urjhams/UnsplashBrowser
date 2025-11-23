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
      
      // Filter duplicates and build both arrays efficiently in one pass
      var uniquePhotos: [UnsplashPhoto] = []
      uniquePhotos.reserveCapacity(response.results.count)
      
      for photo in response.results {
        if loadedPhotoIDs.insert(photo.id).inserted {
          uniquePhotos.append(photo)
        }
      }
      
      photos = uniquePhotos
      hasMorePages = currentPage < response.totalPages
      
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
        
        // Filter duplicates in one pass using Set.insert
        for photo in response.results {
          if loadedPhotoIDs.insert(photo.id).inserted {
            photos.append(photo)
          }
        }
        
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
