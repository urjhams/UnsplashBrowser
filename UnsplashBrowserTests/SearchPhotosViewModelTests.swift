//  SearchPhotosViewModelTests.swift
//  UnsplashBrowserTests

import Foundation
import Testing

@testable import UnsplashBrowser

// Mock API Client for testing
actor MockUnsplashAPIClient: UnsplashAPIClient {
  var mockResponse: UnsplashSearchResponse?
  var shouldThrowError = false
  var callCount = 0

  func searchPhotos(query: String, page: Int, perPage: Int) async throws -> UnsplashSearchResponse {
    callCount += 1

    if shouldThrowError {
      throw NSError(
        domain: "TestError",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Mock error"]
      )
    }

    guard let response = mockResponse else {
      throw NSError(
        domain: "TestError",
        code: -2,
        userInfo: [NSLocalizedDescriptionKey: "No mock response set"]
      )
    }

    return response
  }
}

extension MockUnsplashAPIClient {
  func setMockResponse(_ response: UnsplashSearchResponse) {
    mockResponse = response
  }
  
  func setShouldThrowError(_ shouldThrow: Bool) {
    shouldThrowError = shouldThrow
  }
}


@MainActor
struct SearchPhotosViewModelTests {

  // Helper to create mock photo
  private func createMockPhoto(id: String) -> UnsplashPhoto {
    UnsplashPhoto(
      id: id,
      createdAt: "2024-01-01T00:00:00Z",
      width: 1920,
      height: 1080,
      color: "#000000",
      blurHash: "LEHV6nWB2yk8pyo0adR*.7kCMdnj",
      likes: 100,
      description: "Test photo",
      urls: PhotoURLs(
        raw: "https://example.com/raw",
        full: "https://example.com/full",
        regular: "https://example.com/regular",
        small: "https://example.com/small",
        thumb: "https://example.com/thumb"
      ),
      user: PhotoUser(
        id: "user-1",
        username: "testuser",
        name: "Test User",
        firstName: "Test",
        lastName: "User",
        instagramUsername: nil,
        twitterUsername: nil,
        portfolioUrl: "https://example.com"
      )
    )
  }

  @Test func test_searchSuccess() async throws {
    let mockClient = MockUnsplashAPIClient()
    let mockPhotos = [createMockPhoto(id: "photo-1"), createMockPhoto(id: "photo-2")]
    await mockClient.setMockResponse(
      UnsplashSearchResponse(
        total: 2,
        totalPages: 1,
        results: mockPhotos
      )
    )

    let viewModel = SearchPhotosViewModel(apiClient: mockClient)

    await viewModel.search(query: "test")

    // Assert photos array is populated
    #expect(viewModel.photos.count == 2)
    #expect(viewModel.photos[0].id == "photo-1")
    #expect(viewModel.photos[1].id == "photo-2")

    // Assert loading state is false
    #expect(viewModel.isLoading == false)

    // Assert no error state
    #expect(viewModel.errorMessage == nil)
  }

  @Test func test_emptyResult() async throws {
    let mockClient = MockUnsplashAPIClient()
    await mockClient.setMockResponse(
      UnsplashSearchResponse(
        total: 0,
        totalPages: 0,
        results: []
      )
    )

    let viewModel = SearchPhotosViewModel(apiClient: mockClient)

    await viewModel.search(query: "nonexistent")

    // Assert photos array is empty
    #expect(viewModel.photos.isEmpty)

    // Assert loading state is false
    #expect(viewModel.isLoading == false)

    // Assert no error
    #expect(viewModel.errorMessage == nil)
  }

  @Test func test_errorResult() async throws {
    let mockClient = MockUnsplashAPIClient()
    await mockClient.setShouldThrowError(true)

    let viewModel = SearchPhotosViewModel(apiClient: mockClient)

    await viewModel.search(query: "test")

    // Assert error state is set
    #expect(viewModel.errorMessage != nil)
    #expect(viewModel.errorMessage?.contains("Mock error") == true)

    // Assert loading state is false
    #expect(viewModel.isLoading == false)

    // Assert photos array is empty
    #expect(viewModel.photos.isEmpty)
  }

  @Test func test_pagination() async throws {
    let mockClient = MockUnsplashAPIClient()

    // First page
    let page1Photos = [createMockPhoto(id: "photo-1"), createMockPhoto(id: "photo-2")]
    await mockClient.setMockResponse(
      UnsplashSearchResponse(
        total: 4,
        totalPages: 2,
        results: page1Photos
      )
    )

    let viewModel = SearchPhotosViewModel(apiClient: mockClient)
    await viewModel.search(query: "test")

    #expect(viewModel.photos.count == 2)
    #expect(viewModel.photos[0].id == "photo-1")

    // Second page
    let page2Photos = [createMockPhoto(id: "photo-3"), createMockPhoto(id: "photo-4")]
    await mockClient.setMockResponse(
      UnsplashSearchResponse(
        total: 4,
        totalPages: 2,
        results: page2Photos
      )
    )

    await viewModel.loadMore()

    // Assert second page is appended
    #expect(viewModel.photos.count == 4)
    #expect(viewModel.photos[2].id == "photo-3")
    #expect(viewModel.photos[3].id == "photo-4")

    // Assert no duplicates
    let ids = viewModel.photos.map(\.id)
    let uniqueIds = Set(ids)
    #expect(ids.count == uniqueIds.count)
  }

  @Test func test_emptyQueryClearsPhotos() async throws {
    let mockClient = MockUnsplashAPIClient()
    let mockPhotos = [createMockPhoto(id: "photo-1")]
    await mockClient.setMockResponse(
      UnsplashSearchResponse(
        total: 1,
        totalPages: 1,
        results: mockPhotos
      )
    )

    let viewModel = SearchPhotosViewModel(apiClient: mockClient)

    // First search with valid query
    await viewModel.search(query: "test")
    #expect(viewModel.photos.count == 1)

    // Search with empty query
    await viewModel.search(query: "")
    #expect(viewModel.photos.isEmpty)
  }

}
