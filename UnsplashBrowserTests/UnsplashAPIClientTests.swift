//  UnsplashAPIClientTests.swift
//  UnsplashBrowserTests

import Foundation
import Testing

@testable import UnsplashBrowser

@MainActor
@Suite(.serialized)
struct UnsplashAPIClientTests {

  @Test func test_successDecoding() async throws {
    // Create mock JSON response with valid photo data
    let mockJSON = """
      {
        "total": 133,
        "total_pages": 7,
        "results": [
          {
            "id": "eOLpJytrbsQ",
            "created_at": "2014-11-18T14:35:36-05:00",
            "width": 4000,
            "height": 3000,
            "color": "#A7A2A1",
            "blur_hash": "LaLXMa9Fx[D%~q%MtQM|kDRjtRIU",
            "likes": 286,
            "liked_by_user": false,
            "description": "A man drinking a coffee.",
            "user": {
              "id": "Ul0QVz12Goo",
              "username": "ugmonk",
              "name": "Jeff Sheldon",
              "first_name": "Jeff",
              "last_name": "Sheldon",
              "instagram_username": "instantgrammer",
              "twitter_username": "ugmonk",
              "portfolio_url": "http://ugmonk.com/",
              "profile_image": {
                "small": "https://images.unsplash.com/profile-1441298803695-accd94000cac?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=32&w=32&s=7cfe3b93750cb0c93e2f7caec08b5a41",
                "medium": "https://images.unsplash.com/profile-1441298803695-accd94000cac?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=64&w=64&s=5a9dc749c43ce5bd60870b129a40902f",
                "large": "https://images.unsplash.com/profile-1441298803695-accd94000cac?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=128&w=128&s=32085a077889586df88bfbe406692202"
              },
              "links": {
                "self": "https://api.unsplash.com/users/ugmonk",
                "html": "http://unsplash.com/@ugmonk",
                "photos": "https://api.unsplash.com/users/ugmonk/photos",
                "likes": "https://api.unsplash.com/users/ugmonk/likes"
              }
            },
            "current_user_collections": [],
            "urls": {
              "raw": "https://images.unsplash.com/photo-1416339306562-f3d12fefd36f",
              "full": "https://hd.unsplash.com/photo-1416339306562-f3d12fefd36f",
              "regular": "https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&s=92f3e02f63678acc8416d044e189f515",
              "small": "https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&s=263af33585f9d32af39d165b000845eb",
              "thumb": "https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max&s=8aae34cf35df31a592f0bef16e6342ef"
            },
            "links": {
              "self": "https://api.unsplash.com/photos/eOLpJytrbsQ",
              "html": "http://unsplash.com/photos/eOLpJytrbsQ",
              "download": "http://unsplash.com/photos/eOLpJytrbsQ/download"
            }
          },
        ]
      }
      """.data(using: .utf8)!

    // Configure MockURLProtocol
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, mockJSON)
    }

    // Initialize client with mock session
    let client = UnsplashAPIClientImpl(session: mockSession, accessKey: "test-key")

    // Call searchPhotos
    let result = try await client.searchPhotos(query: "test", page: 1, perPage: 10)

    // Assert response is decoded correctly
    #expect(result.total == 133)
    #expect(result.totalPages == 7)
    #expect(result.results.count == 1)

    let photo = result.results[0]
    #expect(photo.id == "eOLpJytrbsQ")
    #expect(photo.width == 4000)
    #expect(photo.height == 3000)
    #expect(photo.likes == 286)
    #expect(photo.urls.thumb == "https://images.unsplash.com/photo-1416339306562-f3d12fefd36f?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max&s=8aae34cf35df31a592f0bef16e6342ef")
    #expect(photo.user.username == "ugmonk")
    #expect(photo.user.name == "Jeff Sheldon")
  }

  @Test func test_badRequest() async throws {
    // Configure MockURLProtocol to return 400 status
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 400,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, nil)
    }

    let client = UnsplashAPIClientImpl(session: mockSession, accessKey: "test-key")

    do {
      _ = try await client.searchPhotos(query: "test")
      Issue.record("Expected bad request error to be thrown")
    } catch let error as UnsplashAPIError {
      #expect(error == .badRequest)
      #expect(error.localizedDescription.contains("Bad Request"))
      #expect(error.localizedDescription.contains("missing a required parameter"))
    }
  }
  
  @Test func test_unauthorized() async throws {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 401,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, nil)
    }

    let client = UnsplashAPIClientImpl(session: mockSession, accessKey: "test-key")

    do {
      _ = try await client.searchPhotos(query: "test")
      Issue.record("Expected unauthorized error to be thrown")
    } catch let error as UnsplashAPIError {
      #expect(error == .unauthorized)
      #expect(error.localizedDescription.contains("Unauthorized"))
      #expect(error.localizedDescription.contains("Invalid Access Token"))
    }
  }
  
  @Test func test_forbidden() async throws {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 403,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, nil)
    }

    let client = UnsplashAPIClientImpl(session: mockSession, accessKey: "test-key")

    do {
      _ = try await client.searchPhotos(query: "test")
      Issue.record("Expected forbidden error to be thrown")
    } catch let error as UnsplashAPIError {
      #expect(error == .forbidden)
      #expect(error.localizedDescription.contains("Forbidden"))
      #expect(error.localizedDescription.contains("Missing permissions"))
    }
  }
  
  @Test func test_notFound() async throws {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 404,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, nil)
    }

    let client = UnsplashAPIClientImpl(session: mockSession, accessKey: "test-key")

    do {
      _ = try await client.searchPhotos(query: "test")
      Issue.record("Expected not found error to be thrown")
    } catch let error as UnsplashAPIError {
      #expect(error == .notFound)
      #expect(error.localizedDescription.contains("Not Found"))
      #expect(error.localizedDescription.contains("doesn't exist"))
    }
  }
  
  @Test func test_serverError() async throws {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 500,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, nil)
    }

    let client = UnsplashAPIClientImpl(session: mockSession, accessKey: "test-key")

    do {
      _ = try await client.searchPhotos(query: "test")
      Issue.record("Expected server error to be thrown")
    } catch let error as UnsplashAPIError {
      #expect(error == .serverError)
      #expect(error.localizedDescription.contains("Server Error"))
      #expect(error.localizedDescription.contains("went wrong on our end"))
    }
  }

  @Test func test_decodingError() async throws {
    // Create malformed JSON (missing required fields)
    let malformedJSON = """
      {
        "total": 1,
        "results": [
          {
            "id": "test"
          }
        ]
      }
      """.data(using: .utf8)!

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, malformedJSON)
    }

    let client = UnsplashAPIClientImpl(session: mockSession, accessKey: "test-key")

    // Expect decoding error
    await #expect(throws: Error.self) {
      try await client.searchPhotos(query: "test")
    }
  }

  @Test func test_rateLimit() async throws {
    // Configure MockURLProtocol to return 429 status
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 429,
        httpVersion: nil,
        headerFields: ["Retry-After": "60"]
      )!
      return (response, nil)
    }

    let client = UnsplashAPIClientImpl(session: mockSession, accessKey: "test-key")

    // Call searchPhotos and expect rate limit error
    do {
      _ = try await client.searchPhotos(query: "test")
      Issue.record("Expected rate limit error to be thrown")
    } catch let error as UnsplashAPIError {
      #expect(error == .rateLimitExceeded)
      #expect(error.localizedDescription.contains("Rate Limit"))
    }
  }

}
