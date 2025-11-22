// PhotoUser.swift
// Photo user model

import Foundation

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
