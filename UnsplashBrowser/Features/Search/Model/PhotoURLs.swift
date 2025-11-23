// PhotoURLs.swift
// Photo URLs model

import Foundation

struct PhotoURLs: Codable, Hashable {
  let raw: String
  let full: String
  let regular: String
  let small: String
  let thumb: String
}
