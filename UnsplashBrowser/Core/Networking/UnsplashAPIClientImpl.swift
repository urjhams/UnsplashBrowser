// UnsplashAPIClientImpl.swift
// Actor implementation of UnsplashAPIClient

import Foundation

actor UnsplashAPIClientImpl: UnsplashAPIClient {
  private let session: URLSession
  private let accessKey: String

  // Rate limiting properties
  private var lastRequestTime: Date?
  private let minRequestInterval: TimeInterval = 0.1  // 100ms between requests

  init(session: URLSession = .shared, accessKey: String = APIConfig.accessKey) {
    self.session = session
    self.accessKey = accessKey
  }

  func searchPhotos(query: String, page: Int = 1, perPage: Int = 20) async throws -> UnsplashSearchResponse {
    // Rate limiting: ensure minimum interval between requests
    if let lastTime = lastRequestTime {
      let elapsed = Date().timeIntervalSince(lastTime)
      if elapsed < minRequestInterval {
        try await Task.sleep(nanoseconds: UInt64((minRequestInterval - elapsed) * 1_000_000_000))
      }
    }

    lastRequestTime = Date()

    // Build URL with query parameters
    let urlString = await APIConfig.baseURL + APIConfig.Endpoint.searchPhotos
    var components = URLComponents(string: urlString)!
    components.queryItems = [
      URLQueryItem(name: "query", value: query),
      URLQueryItem(name: "page", value: "\(page)"),
      URLQueryItem(name: "per_page", value: "\(perPage)"),
    ]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    // Create request with authorization header
    var request = URLRequest(url: url)
    request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")

    // Perform request
    let (data, response) = try await session.data(for: request)

    // Check HTTP response
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    // Handle HTTP errors
    guard (200...299).contains(httpResponse.statusCode) else {
      throw UnsplashAPIError(statusCode: httpResponse.statusCode)
    }

    // Decode response
    return try await MainActor.run {
      let decoder = JSONDecoder()
      return try decoder.decode(UnsplashSearchResponse.self, from: data)
    }
  }
}
