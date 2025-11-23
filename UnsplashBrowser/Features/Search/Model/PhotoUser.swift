// PhotoUser.swift
// Photo user model

import Foundation

struct UserImages: Codable {
  let small: String
  let medium: String
  let large: String
}

struct UserLinks: Codable {
  let html: String
}

struct PhotoUser: Codable {
  let id: String
  let username: String
  let name: String
  let firstName: String?
  let lastName: String?
  let profileImages: UserImages
  let links: UserLinks
  
  enum CodingKeys: String, CodingKey {
    case id
    case username
    case name
    case firstName = "first_name"
    case lastName = "last_name"
    case profileImages = "profile_image"
    case links = "links"
  }
  
  /// Convert PhotoUser to FavoriteAuthor for persistence
  func toFavoriteAuthor() -> FavoriteAuthor {
    FavoriteAuthor(
      id: id,
      username: username,
      name: name,
      userImage: profileImages.large,
      url: links.html
    )
  }
}
