// PhotoURLs.swift
// Photo URLs model

import Foundation

struct PhotoURLs: Codable {
  let raw: String
  let full: String
  let regular: String
  let small: String
  let thumb: String
}
