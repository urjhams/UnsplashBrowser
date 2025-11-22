//
//  UnsplashAPIClientTests.swift
//  UnsplashBrowserTests
//
//  Created by Quân Đinh on 22.11.25.
//

import Testing
import Foundation
@testable import UnsplashBrowser

struct UnsplashAPIClientTests {

    @Test func test_successDecoding() async throws {
        // Create mock JSON response with valid photo data
        // Configure MockURLProtocol to return this JSON with 200 status
        // Create URLSession with mock protocol
        // Initialize UnsplashAPIClientImpl with mock session
        // Call searchPhotos() with test query
        // Assert response is decoded correctly
        // Assert photo count matches expected
        // Assert photo properties (id, urls, user) are valid
    }
    
    @Test func test_httpError() async throws {
        // Configure MockURLProtocol to return 500 status code
        // Create URLSession with mock protocol
        // Initialize UnsplashAPIClientImpl with mock session
        // Call searchPhotos() and expect it to throw
        // Assert error type is HTTP error
        // Assert status code is 500
    }
    
    @Test func test_decodingError() async throws {
        // Create malformed JSON response (missing required fields)
        // Configure MockURLProtocol to return malformed JSON with 200 status
        // Create URLSession with mock protocol
        // Initialize UnsplashAPIClientImpl with mock session
        // Call searchPhotos() and expect it to throw
        // Assert error is decoding error
    }
    
    @Test func test_rateLimit() async throws {
        // Configure MockURLProtocol to return 429 (rate limit) status
        // Optionally include Retry-After header
        // Create URLSession with mock protocol
        // Initialize UnsplashAPIClientImpl with mock session
        // Call searchPhotos() and expect it to throw
        // Assert error indicates rate limiting
        // Verify rate limit is handled appropriately
    }

}
