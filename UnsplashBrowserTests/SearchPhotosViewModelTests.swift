//
//  SearchPhotosViewModelTests.swift
//  UnsplashBrowserTests
//
//  Created by Quân Đinh on 22.11.25.
//

import Testing
import Foundation
@testable import UnsplashBrowser

struct SearchPhotosViewModelTests {

    @Test func test_searchSuccess() async throws {
        // Create mock UnsplashAPIClient that returns sample photos
        // Initialize SearchPhotosViewModel with mock client
        // Set search query
        // Wait for debounce period
        // Assert photos array is populated
        // Assert loading state is false
        // Assert no error state
    }
    
    @Test func test_emptyResult() async throws {
        // Create mock UnsplashAPIClient that returns empty results
        // Initialize SearchPhotosViewModel with mock client
        // Set search query
        // Wait for debounce period
        // Assert photos array is empty
        // Assert loading state is false
        // Assert appropriate empty state is shown
    }
    
    @Test func test_errorResult() async throws {
        // Create mock UnsplashAPIClient that throws error
        // Initialize SearchPhotosViewModel with mock client
        // Set search query
        // Wait for debounce period
        // Assert error state is set
        // Assert loading state is false
        // Assert photos array remains empty or previous state
    }
    
    @Test func test_pagination() async throws {
        // Create mock UnsplashAPIClient with paginated responses
        // Initialize SearchPhotosViewModel with mock client
        // Perform initial search
        // Assert first page of photos is loaded
        // Trigger pagination (loadMore)
        // Assert second page is appended to photos array
        // Assert page number is incremented
        // Assert no duplicate photos
    }
    
    @Test func test_debounceCancelsPrevious() async throws {
        // Create mock UnsplashAPIClient that tracks call count
        // Initialize SearchPhotosViewModel with mock client
        // Rapidly change search query multiple times
        // Wait for debounce period
        // Assert API was called only once (for last query)
        // Assert previous searches were cancelled
        // Assert photos correspond to final query only
    }

}
