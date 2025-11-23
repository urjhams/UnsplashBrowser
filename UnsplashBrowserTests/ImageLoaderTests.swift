//
//  ImageLoaderTests.swift
//  UnsplashBrowserTests
//
//  Created by Quân Đinh on 22.11.25.
//

import Foundation
import Testing
import UIKit

@testable import UnsplashBrowser

@Suite(.serialized)
struct ImageLoaderTests {
  
  // Helper to create a simple test image
  private func createTestImage() -> UIImage {
    let size = CGSize(width: 100, height: 100)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
      UIColor.red.setFill()
      context.fill(CGRect(origin: .zero, size: size))
    }
  }
  
  // Helper to create test image data
  private func createTestImageData() -> Data {
    let image = createTestImage()
    return image.pngData()!
  }

  @Test func test_cacheHit() async throws {
    // Create test image data
    let imageData = createTestImageData()
    let testURL = URL(string: "https://example.com/test-image.jpg")!
    
    // Configure MockURLProtocol
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)
    
    var requestCount = 0
    MockURLProtocol.requestHandler = { request in
      requestCount += 1
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, imageData)
    }
    
    let loader = await ImageLoaderImpl(session: mockSession)
    
    // First load - should hit network
    let image1 = try await loader.loadImage(from: testURL)
    #expect(requestCount == 1)
    #expect(image1.size.width == 100)
    #expect(image1.size.height == 100)
    
    // Second load - should hit cache
    let image2 = try await loader.loadImage(from: testURL)
    #expect(requestCount == 1)  // Still 1, no additional request
    #expect(image2.size.width == 100)
  }

  @Test func test_cacheMissLoads() async throws {
    let imageData = createTestImageData()
    let testURL = URL(string: "https://example.com/new-image.jpg")!
    
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
      return (response, imageData)
    }
    
    let loader = await ImageLoaderImpl(session: mockSession)
    
    // Load image - cache miss, should fetch from network
    let image = try await loader.loadImage(from: testURL)
    
    // Verify image properties
    #expect(image.size.width == 100)
    #expect(image.size.height == 100)
    
    // Verify image was cached by loading again
    var secondRequestMade = false
    MockURLProtocol.requestHandler = { request in
      secondRequestMade = true
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, imageData)
    }
    
    _ = try await loader.loadImage(from: testURL)
    #expect(!secondRequestMade)  // Should use cache, no second request
  }

  @Test func test_dedupesParallelRequests() async throws {
    let imageData = createTestImageData()
    let testURL = URL(string: "https://example.com/parallel-image.jpg")!
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)
    
    var requestCount = 0
    MockURLProtocol.requestHandler = { request in
      requestCount += 1
      // Simulate slow network
      usleep(100_000) // 0.1 second
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, imageData)
    }
    
    let loader = await ImageLoaderImpl(session: mockSession)
    
    // Launch multiple parallel requests for same URL
    async let image1 = loader.loadImage(from: testURL)
    async let image2 = loader.loadImage(from: testURL)
    async let image3 = loader.loadImage(from: testURL)
    async let image4 = loader.loadImage(from: testURL)
    async let image5 = loader.loadImage(from: testURL)
    
    // Await all tasks
    let results = try await [image1, image2, image3, image4, image5]
    
    // Assert all tasks returned images
    #expect(results.count == 5)
    for image in results {
      #expect(image.size.width == 100)
      #expect(image.size.height == 100)
    }
    
    // Assert only ONE network request was made (deduplication works!)
    #expect(requestCount == 1)
  }

  @Test func test_networkError() async throws {
    let testURL = URL(string: "https://example.com/error-image.jpg")!
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let mockSession = URLSession(configuration: config)
    
    // Configure to return network error
    MockURLProtocol.requestHandler = { request in
      throw URLError(.notConnectedToInternet)
    }
    
    let loader = await ImageLoaderImpl(session: mockSession)
    
    // Expect error to be thrown
    await #expect(throws: Error.self) {
      try await loader.loadImage(from: testURL)
    }
    
    // Try again to ensure error wasn't cached
    await #expect(throws: Error.self) {
      try await loader.loadImage(from: testURL)
    }
  }
  
  @Test func test_invalidImageData() async throws {
    let testURL = URL(string: "https://example.com/invalid-image.jpg")!
    let invalidData = "Not an image".data(using: .utf8)!
    
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
      return (response, invalidData)
    }
    
    let loader = await ImageLoaderImpl(session: mockSession)
    
    // Expect decoding error
    do {
      _ = try await loader.loadImage(from: testURL)
      Issue.record("Expected image decoding error to be thrown")
    } catch {
      #expect(error.localizedDescription.contains("Failed to decode image"))
    }
  }
  
  @Test func test_badServerResponse() async throws {
    let testURL = URL(string: "https://example.com/bad-response.jpg")!
    let imageData = createTestImageData()
    
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
      return (response, imageData)
    }
    
    let loader = await ImageLoaderImpl(session: mockSession)
    
    // Expect bad server response error
    await #expect(throws: URLError.self) {
      try await loader.loadImage(from: testURL)
    }
  }

}
