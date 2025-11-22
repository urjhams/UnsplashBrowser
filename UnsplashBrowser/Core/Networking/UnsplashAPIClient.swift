// UnsplashAPIClient.swift
// Protocol for Unsplash API interactions

import Foundation

/// Represents a photo from the Unsplash API
struct UnsplashPhoto: Codable, Identifiable {
  let id: String
  let description: String?
  let urls: PhotoURLs
  let user: User
  let width: Int
  let height: Int
  let likes: Int

  struct PhotoURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
  }

  struct User: Codable {
    let id: String
    let username: String
    let name: String
    let portfolioUrl: String?

    enum CodingKeys: String, CodingKey {
      case id
      case username
      case name
      case portfolioUrl = "portfolio_url"
    }
  }
}

/// Response from the search photos endpoint
struct UnsplashSearchResponse: Codable {
  let total: Int
  let totalPages: Int
  let results: [UnsplashPhoto]

  enum CodingKeys: String, CodingKey {
    case total
    case totalPages = "total_pages"
    case results
  }
}

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
