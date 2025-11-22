//
//  FavoriteAuthorsStoreTests.swift
//  UnsplashBrowserTests
//
//  Created by Quân Đinh on 22.11.25.
//

import Foundation
import Testing

@testable import UnsplashBrowser

@MainActor
struct FavoriteAuthorsStoreTests {

  // Helper to clear UserDefaults before each test
  private func clearDefaults() {
    UserDefaults.standard.removeObject(forKey: "favoriteAuthors")
  }

  @Test func test_toggleAdds() async throws {
    clearDefaults()

    let store = FavoriteAuthorsStore()
    let testAuthor = FavoriteAuthor(
      id: "test-1",
      username: "testuser",
      name: "Test User",
      portfolioUrl: "https://example.com"
    )

    // Assert author is not initially favorited
    #expect(!store.isFavorite(testAuthor.id))
    #expect(store.favorites.isEmpty)

    // Call toggleFavorite() to add author
    store.toggleFavorite(testAuthor)

    // Assert author is now favorited
    #expect(store.isFavorite(testAuthor.id))
    #expect(store.favorites.contains(testAuthor))
    #expect(store.favorites.count == 1)
  }

  @Test func test_toggleRemoves() async throws {
    clearDefaults()

    let store = FavoriteAuthorsStore()
    let testAuthor = FavoriteAuthor(
      id: "test-2",
      username: "testuser2",
      name: "Test User 2",
      portfolioUrl: "https://example.com/2"
    )

    // Add author to favorites
    store.toggleFavorite(testAuthor)
    #expect(store.isFavorite(testAuthor.id))
    #expect(store.favorites.count == 1)

    // Call toggleFavorite() again to remove author
    store.toggleFavorite(testAuthor)

    // Assert author is no longer favorited
    #expect(!store.isFavorite(testAuthor.id))
    #expect(!store.favorites.contains(testAuthor))
    #expect(store.favorites.isEmpty)
  }

  @Test func test_persistedLoad() async throws {
    clearDefaults()

    let author1 = FavoriteAuthor(
      id: "test-3",
      username: "user1",
      name: "User One",
      portfolioUrl: "https://example.com/1"
    )
    let author2 = FavoriteAuthor(
      id: "test-4",
      username: "user2",
      name: "User Two",
      portfolioUrl: nil
    )

    // Create first store and add authors
    do {
      let store1 = FavoriteAuthorsStore()
      store1.toggleFavorite(author1)
      store1.toggleFavorite(author2)

      #expect(store1.favorites.count == 2)
    }

    // Create new store instance - should load persisted data
    let store2 = FavoriteAuthorsStore()

    // Assert favorites are loaded from persistence
    #expect(store2.favorites.count == 2)
    #expect(store2.favorites.contains(author1))
    #expect(store2.favorites.contains(author2))
    #expect(store2.isFavorite(author1.id))
    #expect(store2.isFavorite(author2.id))
  }

  @Test func test_isFavorite() async throws {
    clearDefaults()

    let store = FavoriteAuthorsStore()
    let testAuthor = FavoriteAuthor(
      id: "test-5",
      username: "testuser5",
      name: "Test User 5",
      portfolioUrl: "https://example.com/5"
    )

    // Assert isFavorite returns false for non-existent author
    #expect(!store.isFavorite(testAuthor.id))
    #expect(!store.isFavorite("non-existent-id"))

    // Add author to favorites
    store.toggleFavorite(testAuthor)

    // Assert isFavorite returns true for added author
    #expect(store.isFavorite(testAuthor.id))

    // Assert isFavorite still returns false for non-existent author
    #expect(!store.isFavorite("another-non-existent-id"))

    // Remove author from favorites
    store.toggleFavorite(testAuthor)

    // Assert isFavorite now returns false
    #expect(!store.isFavorite(testAuthor.id))
  }

}
