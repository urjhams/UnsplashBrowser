// UnsplashSearchResponse.swift
// Search response model

import Foundation

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
