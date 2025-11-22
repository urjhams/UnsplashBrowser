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

struct ImageLoaderTests {

  @Test func test_cacheHit() async throws {
    // Create ImageLoaderImpl with mock URLSession
    // Create test URL and sample image data
    // Pre-populate cache by loading image once
    // Clear MockURLProtocol request handler to ensure no network call
    // Load same image again
    // Assert image is returned successfully
    // Assert no network request was made (cache hit)
  }

  @Test func test_cacheMissLoads() async throws {
    // Create ImageLoaderImpl with mock URLSession
    // Create test URL and sample image data
    // Configure MockURLProtocol to return image data
    // Load image from URL (cache miss)
    // Assert image is loaded successfully from network
    // Assert image is cached for future use
    // Verify image properties (size, format)
  }

  @Test func test_dedupesParallelRequests() async throws {
    // Create ImageLoaderImpl with mock URLSession
    // Create test URL and sample image data
    // Add counter in MockURLProtocol to track request count
    // Launch multiple parallel load tasks for same URL
    // Await all tasks to complete
    // Assert all tasks return same image
    // Assert only ONE network request was made (deduplication works)
  }

  @Test func test_networkError() async throws {
    // Create ImageLoaderImpl with mock URLSession
    // Create test URL
    // Configure MockURLProtocol to throw network error
    // Call loadImage() and expect it to throw
    // Assert error is network-related
    // Assert image is not cached on error
  }

}
