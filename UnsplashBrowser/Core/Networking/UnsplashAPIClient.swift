// UnsplashAPIClient.swift
// Protocol for Unsplash API interactions

import Foundation

/// Protocol defining the Unsplash API client interface
protocol UnsplashAPIClient {
  /// Searches for photos matching the given query
  /// - Parameters:
  ///   - query: The search term
  ///   - page: The page number (default: 1)
  ///   - perPage: Number of results per page (default: 20)
  /// - Returns: Search response containing photos
  func searchPhotos(query: String, page: Int, perPage: Int) async throws -> UnsplashSearchResponse
}
