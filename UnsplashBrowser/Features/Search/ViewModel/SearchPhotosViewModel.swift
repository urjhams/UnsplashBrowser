// SearchPhotosViewModel.swift
// @Observable class managing search state and pagination

import Foundation

/// ViewModel managing photo search functionality with pagination support.
/// Handles API calls, duplicate filtering, and loading states.
@MainActor
@Observable
class SearchPhotosViewModel {
  // Dependencies
  private let apiClient: UnsplashAPIClient
  
  // MARK: - Public Properties
  
  /// Array of loaded photos from search results
  var photos: [UnsplashPhoto] = []
  
  /// Indicates whether an API request is in progress
  var isLoading = false
  
  /// Optional message to display (errors or empty states)
  var message: String?
  
  /// Current search query string
  var searchQuery = ""
  
  // MARK: - Private Properties
  
  /// Current page number for pagination
  private var currentPage = 1
  
  /// Indicates if more pages are available to load
  private var hasMorePages = true
  
  /// Task reference for managing concurrent load operations
  private var loadTask: Task<Void, Never>?
  
  /// Set tracking all loaded photo IDs to prevent duplicates
  private var loadedPhotoIDs = Set<String>()
  
  init(apiClient: UnsplashAPIClient) {
    self.apiClient = apiClient
  }
  
  // MARK: - Public Methods
  
  /// Calculates the index of the last row in a grid layout.
  /// - Parameter photoPerRow: Number of photos displayed per row
  /// - Returns: Zero-based index of the last row
  func lastRowIndex(_ photoPerRow: Int) -> Int {
    photos.count > photoPerRow ? photoPerRow - photoPerRow : photos.count - 1
  }
  
  // MARK: - Private Methods
  
  /// Resets search state and prepares for a new search operation.
  /// - Parameter query: The search query string to initialize with
  private func resetSearchState(query: String) {
    loadTask?.cancel()
    loadTask = nil
    searchQuery = query
    currentPage = 1
    hasMorePages = true
    isLoading = true
    message = "Searching for \"\(query)\"..."
    loadedPhotoIDs.removeAll()
  }

  /// Performs a new search with the given query string.
  /// Resets pagination state and loads the first page of results.
  /// Filters out duplicate photos based on their IDs.
  /// - Parameter query: The search term to query for photos
  func search(query: String) async {
    guard !query.isEmpty else {
      photos = []
      return
    }

    resetSearchState(query: query)

    do {
      let response = try await apiClient.searchPhotos(
        query: query,
        page: currentPage,
        perPage: 30
      )
      
      // Filter duplicates and build array efficiently in one pass
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

  /// Loads the next page of search results and appends unique photos.
  /// Prevents concurrent load operations and checks for availability of more pages.
  /// Only adds photos that haven't been loaded before (based on ID).
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
          perPage: 30
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
        currentPage -= 1 // Rollback page increment on error
      }

      isLoading = false
      loadTask = nil
    }
    
    await loadTask?.value
  }
}
