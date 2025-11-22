// UnsplashModels.swift
// Decodable models for Unsplash API responses

import Foundation

// MARK: - Search Response

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

// MARK: - Photo

struct UnsplashPhoto: Codable, Identifiable {
  let id: String
  let createdAt: String
  let width: Int
  let height: Int
  let color: String?
  let blurHash: String?
  let likes: Int
  let description: String?
  let urls: PhotoURLs
  let user: PhotoUser
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case width
    case height
    case color
    case blurHash = "blur_hash"
    case likes
    case description
    case urls
    case user
  }
}

// MARK: - Photo URLs

struct PhotoURLs: Codable {
  let raw: String
  let full: String
  let regular: String
  let small: String
  let thumb: String
}

// MARK: - Photo User

struct PhotoUser: Codable {
  let id: String
  let username: String
  let name: String
  let firstName: String?
  let lastName: String?
  let instagramUsername: String?
  let twitterUsername: String?
  let portfolioUrl: String?
  
  enum CodingKeys: String, CodingKey {
    case id
    case username
    case name
    case firstName = "first_name"
    case lastName = "last_name"
    case instagramUsername = "instagram_username"
    case twitterUsername = "twitter_username"
    case portfolioUrl = "portfolio_url"
  }
  
  /// Convert PhotoUser to FavoriteAuthor for persistence
  func toFavoriteAuthor() -> FavoriteAuthor {
    FavoriteAuthor(
      id: id,
      username: username,
      name: name,
      portfolioUrl: portfolioUrl
    )
  }
}
