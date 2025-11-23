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

    searchQuery = query
    currentPage = 1
    hasMorePages = true
    isLoading = true
    message = "Searching for \"\(query)\"..."

    do {
      let response = try await apiClient.searchPhotos(
        query: query,
        page: currentPage,
        perPage: 30
      )
      photos = response.results
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

    isLoading = true
    currentPage += 1

    do {
      let response = try await apiClient.searchPhotos(
        query: searchQuery,
        page: currentPage,
        perPage: 20
      )
      photos.append(contentsOf: response.results)
      hasMorePages = currentPage < response.totalPages
    } catch {
      message = error.localizedDescription
      currentPage -= 1
    }

    isLoading = false
  }
}
