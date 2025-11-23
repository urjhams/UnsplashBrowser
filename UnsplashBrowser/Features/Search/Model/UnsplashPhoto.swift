// UnsplashPhoto.swift
// Photo model

import Foundation

struct UnsplashPhoto: Codable, Identifiable, Hashable {
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
