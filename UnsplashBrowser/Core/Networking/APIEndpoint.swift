// APIConfig.swift
// Configuration for Unsplash API

import Foundation

enum APIConfig {
  static let baseURL = "https://api.unsplash.com/"
  static let accessKey = Secret.accessKey

  enum Endpoint {
    static let searchPhotos = "search/photos"
  }
}

enum HTTPMethod: String {
  case get = "GET"
}

struct APIEndPoint {
  let path: String
  let method: HTTPMethod
  let queryItems: [URLQueryItem]?
  let headers: [String: String]?
}


extension APIEndPoint {
  /// Search photos on Unsplash
  /// - Parameters:
  ///   - query: Search terms
  ///   - page: Page number to retrieve (default: 1)
  ///   - perPage: Number of items per page (default: 10)
  ///   - orderBy: How to sort the photos (default: relevant). Valid values: "latest", "relevant"
  ///   - collections: Collection ID(s) to narrow search. If multiple, comma-separated
  ///   - contentFilter: Limit results by content safety (default: low). Valid values: "low", "high"
  ///   - color: Filter results by color. Valid values: "black_and_white", "black", "white", "yellow", 
  ///   "orange", "red", "purple", "magenta", "green", "teal", "blue"
  ///   - orientation: Filter by photo orientation. Valid values: "landscape", "portrait", "squarish"
  static func searchPhotos(
    query: String,
    page: Int = 1,
    perPage: Int = 10,
    orderBy: String? = nil,
    collections: String? = nil,
    contentFilter: String? = nil,
    color: String? = nil,
    orientation: String? = nil
  ) -> APIEndPoint {
    var queryItems: [URLQueryItem] = [
      URLQueryItem(name: "query", value: query),
      URLQueryItem(name: "page", value: "\(page)"),
      URLQueryItem(name: "per_page", value: "\(perPage)")
    ]
    
    if let orderBy = orderBy {
      queryItems.append(URLQueryItem(name: "order_by", value: orderBy))
    }
    
    if let collections = collections {
      queryItems.append(URLQueryItem(name: "collections", value: collections))
    }
    
    if let contentFilter = contentFilter {
      queryItems.append(URLQueryItem(name: "content_filter", value: contentFilter))
    }
    
    if let color = color {
      queryItems.append(URLQueryItem(name: "color", value: color))
    }
    
    if let orientation = orientation {
      queryItems.append(URLQueryItem(name: "orientation", value: orientation))
    }
    
    let headers = [
      "Authorization": "Client-ID \(APIConfig.accessKey)"
    ]
    
    return APIEndPoint(
      path: APIConfig.Endpoint.searchPhotos,
      method: .get,
      queryItems: queryItems,
      headers: headers
    )
  }
}
