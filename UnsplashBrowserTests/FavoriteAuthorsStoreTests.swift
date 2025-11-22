//
//  FavoriteAuthorsStoreTests.swift
//  UnsplashBrowserTests
//
//  Created by Quân Đinh on 22.11.25.
//

import Testing
import Foundation
@testable import UnsplashBrowser

struct FavoriteAuthorsStoreTests {

    @Test func test_toggleAdds() async throws {
        // Create FavoriteAuthorsStore instance with fresh UserDefaults
        // Create test author (id, username, name, portfolioUrl)
        // Assert author is not initially favorited
        // Call toggleFavorite() to add author
        // Assert author is now favorited
        // Assert favorites array contains the author
        // Assert favorites count increased by 1
    }
    
    @Test func test_toggleRemoves() async throws {
        // Create FavoriteAuthorsStore instance with fresh UserDefaults
        // Create test author and add to favorites
        // Assert author is favorited
        // Call toggleFavorite() again to remove author
        // Assert author is no longer favorited
        // Assert favorites array does not contain the author
        // Assert favorites count decreased by 1
    }
    
    @Test func test_persistedLoad() async throws {
        // Create FavoriteAuthorsStore instance with test UserDefaults suite
        // Add multiple test authors to favorites
        // Encode favorites to JSON and save to UserDefaults
        // Create new FavoriteAuthorsStore instance with same UserDefaults suite
        // Assert favorites are loaded from persistence
        // Assert all authors are present with correct data
        // Assert order is preserved if applicable
    }
    
    @Test func test_isFavorite() async throws {
        // Create FavoriteAuthorsStore instance
        // Create test author and add to favorites
        // Assert isFavorite(authorId) returns true for added author
        // Assert isFavorite(authorId) returns false for non-existent author
        // Remove author from favorites
        // Assert isFavorite(authorId) now returns false
    }

}
